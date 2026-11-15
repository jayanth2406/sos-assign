#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
    char buffer[16];
    const char *input;

    if (argc < 2 || strcmp(argv[1], "short") == 0) {
        input = "OK";
    } else if (strcmp(argv[1], "long") == 0) {
        /* Fixed benign test string; never accept an arbitrary payload. */
        input = "THIS_INPUT_IS_LONGER_THAN_SIXTEEN";
    } else {
        fprintf(stderr, "Usage: %s [short|long]\n", argv[0]);
        return 2;
    }

    printf("Selected %s input: copying %zu bytes into a 16-byte buffer...\n",
           (strlen(input) < sizeof buffer) ? "short" : "long",
           strlen(input) + 1);
    /* INTENTIONALLY UNSAFE for the long case: observation only. */
    memcpy(buffer, input, strlen(input) + 1);
    printf("Program reached the end of the copy.\n");
    return 0;
}
