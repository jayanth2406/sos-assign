#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>

int main(void) {
    int fd = open("hello.txt", O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd == -1) {
        perror("open");
        return 1;
    }

    const char msg[] = "Hello from user space!\n";
    size_t written = 0;
    while (written < sizeof(msg) - 1) {
        ssize_t n = write(fd, msg + written, sizeof(msg) - 1 - written);
        if (n == -1 && errno == EINTR)
            continue;
        if (n == -1) {
            perror("write");
            close(fd);
            return 1;
        }
        if (n == 0) {
            fprintf(stderr, "write returned zero before the message was complete\n");
            close(fd);
            return 1;
        }
        written += (size_t)n;
    }

    if (close(fd) == -1) {
        perror("close");
        return 1;
    }
    return 0;
}
