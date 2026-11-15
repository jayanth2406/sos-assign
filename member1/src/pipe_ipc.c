#include <errno.h>
#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    int fd[2];
    if (pipe(fd) == -1) {
        perror("pipe");
        return 1;
    }
    /* Turn a closed reader into an EPIPE error so cleanup can run. */
    (void)signal(SIGPIPE, SIG_IGN);

    pid_t pid = fork();
    if (pid == -1) {
        perror("fork");
        close(fd[0]);
        close(fd[1]);
        return 1;
    }

    if (pid == 0) {
        close(fd[1]); /* Child only reads. */
        char buffer[128] = {0};
        size_t used = 0;
        int got_terminator = 0;
        while (used < sizeof(buffer) - 1 && !got_terminator) {
            ssize_t n = read(fd[0], buffer + used, sizeof(buffer) - 1 - used);
            if (n == -1 && errno == EINTR)
                continue;
            if (n == -1) {
                perror("read");
                close(fd[0]);
                return 1;
            }
            if (n == 0)
                break;
            for (ssize_t i = 0; i < n; i++) {
                if (buffer[used + (size_t)i] == '\0') {
                    got_terminator = 1;
                    used += (size_t)i;
                    break;
                }
            }
            if (!got_terminator)
                used += (size_t)n;
        }
        buffer[used] = '\0';
        if (!got_terminator) {
            fprintf(stderr, "message ended without NUL terminator or exceeded buffer\n");
            close(fd[0]);
            return 1;
        }
        printf("Child received: %s\n", buffer);
        close(fd[0]);
        return 0;
    }

    close(fd[0]); /* Parent only writes. */
    const char msg[] = "Hello from the parent";
    size_t remaining = sizeof(msg); /* Include NUL for this string protocol. */
    const char *next = msg;
    while (remaining > 0) {
        ssize_t n = write(fd[1], next, remaining);
        if (n == -1 && errno == EINTR)
            continue;
        if (n == -1) {
            perror("write");
            close(fd[1]);
            (void)waitpid(pid, NULL, 0);
            return 1;
        }
        if (n == 0) {
            fprintf(stderr, "write returned zero before message was complete\n");
            close(fd[1]);
            (void)waitpid(pid, NULL, 0);
            return 1;
        }
        next += n;
        remaining -= (size_t)n;
    }
    close(fd[1]);
    int status;
    if (waitpid(pid, &status, 0) == -1) {
        perror("waitpid");
        return 1;
    }
    return WIFEXITED(status) ? WEXITSTATUS(status) : 1;
}
