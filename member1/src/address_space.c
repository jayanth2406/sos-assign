#include <stdio.h>
#include <unistd.h>

int main(void) {
    int secret = 12345;

    printf("PID       = %d\n", (int)getpid());
    printf("&secret   = %p\n", (void *)&secret);
    printf("secret    = %d\n", secret);
    printf("Inspect /proc/%d/maps for 30 seconds.\n", (int)getpid());
    fflush(stdout);
    sleep(30);

    return 0;
}
