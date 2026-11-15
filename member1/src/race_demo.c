/* Intentionally data-racy teaching example. Do not use as production code. */
#include <pthread.h>
#include <stdio.h>

long counter = 0;

static void *worker(void *arg) {
    (void)arg;
    for (long i = 0; i < 1000000; i++) {
        /* INTENTIONALLY UNSYNCHRONIZED critical section for Mission 5. */
        counter++;
    }
    return NULL;
}

int main(void) {
    pthread_t t1, t2;
    int rc = pthread_create(&t1, NULL, worker, NULL);
    if (rc != 0) {
        fprintf(stderr, "pthread_create thread 1 failed: %d\n", rc);
        return 1;
    }
    rc = pthread_create(&t2, NULL, worker, NULL);
    if (rc != 0) {
        fprintf(stderr, "pthread_create thread 2 failed: %d\n", rc);
        (void)pthread_join(t1, NULL);
        return 1;
    }
    int join1 = pthread_join(t1, NULL);
    int join2 = pthread_join(t2, NULL);
    if (join1 != 0 || join2 != 0) {
        fprintf(stderr, "pthread_join failed (thread 1=%d, thread 2=%d)\n", join1, join2);
        return 1;
    }
    printf("Expected: 2000000\nActual  : %ld\n", counter);
    return 0;
}
