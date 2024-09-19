#include <stdint.h>
#include <stdio.h>

uint32_t fnv1a(const char *str) {
    uint32_t hash = 2166136261U;  // FNV offset basis
    while (*str && *str != '\n') {
        hash ^= (unsigned char)*str++;
        hash *= 16777619;  // FNV prime
    }
    return hash;
}

int main() {
    char buf[256] = {0};
    printf("Enter a string: ");
    fgets(buf, sizeof(buf), stdin);
    printf("Hash: %u\n", fnv1a(buf));
}
