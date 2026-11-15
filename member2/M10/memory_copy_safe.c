#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
    char buffer[16];
    const char *input;

    if (argc < 2 || strcmp(argv[1], "short") == 0) {
        input = "OK";
    } else if (strcmp(argv[1], "long") == 0) {
        input = "THIS_INPUT_IS_LONGER_THAN_SIXTEEN";
    } else {
        fprintf(stderr, "Usage: %s [short|long]\n", argv[0]);
        return 2;
    }

    size_t input_size = strlen(input) + 1; /* include NUL */
    printf("Selected %s input: %zu bytes; capacity is %zu bytes.\n",
           (input_size <= sizeof buffer) ? "short" : "long",
           input_size, sizeof buffer);
    if (input_size > sizeof buffer) {
        fprintf(stderr, "Rejected: input does not fit in destination.\n");
        return 1;
    }

    memcpy(buffer, input, input_size);
    printf("Safe copy complete: %s\n", buffer);
    return 0;
}
