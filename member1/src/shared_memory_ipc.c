/*
 * Team-authored Mission 6 comparison example (not supplied by the instructor).
 * A 0600 POSIX shared-memory object is mapped by the parent, then inherited by
 * its child. Process-shared semaphores publish the message and acknowledge its
 * read so neither process races with the other or unmaps too early.
 */
#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <fcntl.h>
#include <semaphore.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

struct shared_message {
    sem_t ready;
    sem_t acknowledged;
    char text[128];
};

static int wait_semaphore(sem_t *sem) {
    while (sem_wait(sem) == -1) {
        if (errno != EINTR)
            return -1;
    }
    return 0;
}

static int wait_semaphore_timeout(sem_t *sem, int seconds) {
    struct timespec deadline;
    if (clock_gettime(CLOCK_REALTIME, &deadline) == -1)
        return -1;
    deadline.tv_sec += seconds;
    while (sem_timedwait(sem, &deadline) == -1) {
        if (errno != EINTR)
            return -1;
    }
    return 0;
}

int main(void) {
    char name[64];
    (void)snprintf(name, sizeof(name), "/securelab_m06_%ld", (long)getpid());

    int fd = shm_open(name, O_CREAT | O_EXCL | O_RDWR, S_IRUSR | S_IWUSR);
    if (fd == -1) {
        perror("shm_open");
        return 1;
    }
    if (ftruncate(fd, (off_t)sizeof(struct shared_message)) == -1) {
        perror("ftruncate");
        close(fd);
        shm_unlink(name);
        return 1;
    }

    struct shared_message *shared = mmap(NULL, sizeof(*shared),
        PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (shared == MAP_FAILED) {
        perror("mmap");
        close(fd);
        shm_unlink(name);
        return 1;
    }
    memset(shared, 0, sizeof(*shared));
    if (sem_init(&shared->ready, 1, 0) == -1) {
        perror("sem_init ready");
        munmap(shared, sizeof(*shared));
        close(fd);
        shm_unlink(name);
        return 1;
    }
    if (sem_init(&shared->acknowledged, 1, 0) == -1) {
        perror("sem_init acknowledged");
        sem_destroy(&shared->ready);
        munmap(shared, sizeof(*shared));
        close(fd);
        shm_unlink(name);
        return 1;
    }

    pid_t pid = fork();
    if (pid == -1) {
        perror("fork");
        sem_destroy(&shared->acknowledged);
        sem_destroy(&shared->ready);
        munmap(shared, sizeof(*shared));
        close(fd);
        shm_unlink(name);
        return 1;
    }

    if (pid == 0) {
        if (wait_semaphore(&shared->ready) == -1) {
            perror("sem_wait ready");
            _exit(1);
        }
        printf("Child read shared memory: %s\n", shared->text);
        fflush(stdout);
        if (sem_post(&shared->acknowledged) == -1) {
            perror("sem_post acknowledged");
            _exit(1);
        }
        munmap(shared, sizeof(*shared));
        close(fd);
        _exit(0);
    }

    const char message[] = "Hello through shared memory";
    memcpy(shared->text, message, sizeof(message));
    printf("Parent wrote shared memory; object mode is 0600.\n");
    fflush(stdout);
    if (sem_post(&shared->ready) == -1) {
        perror("sem_post ready");
        (void)kill(pid, SIGTERM);
        (void)waitpid(pid, NULL, 0);
        sem_destroy(&shared->acknowledged);
        sem_destroy(&shared->ready);
        munmap(shared, sizeof(*shared));
        close(fd);
        shm_unlink(name);
        return 1;
    }
    if (wait_semaphore_timeout(&shared->acknowledged, 5) == -1) {
        perror("sem_timedwait acknowledged");
        /* Do not hang forever if the child failed before acknowledging. */
        (void)kill(pid, SIGTERM);
        (void)waitpid(pid, NULL, 0);
        sem_destroy(&shared->acknowledged);
        sem_destroy(&shared->ready);
        munmap(shared, sizeof(*shared));
        close(fd);
        shm_unlink(name);
        return 1;
    }
    int status;
    if (waitpid(pid, &status, 0) == -1) {
        perror("waitpid");
        status = 1;
    }

    sem_destroy(&shared->acknowledged);
    sem_destroy(&shared->ready);
    munmap(shared, sizeof(*shared));
    close(fd);
    shm_unlink(name);
    return WIFEXITED(status) ? WEXITSTATUS(status) : 1;
}
