#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NAME_SIZE      64
#define PATH_SIZE     256
#define BOOKMARK_SIZE 321

char *bookmarks_filename = "jumprc";

typedef struct bookmark_struct bookmark;
struct bookmark_struct {
    char name[NAME_SIZE];
    char path[PATH_SIZE];
    bookmark *next;
};

bookmark *bookmarks = NULL;

void exit_with_error(char *message) {
    printf("*** ERROR: %s\n", message);
    exit(1);
}

void print_usage() {
    printf("...usage...");
}

char *pwd() {
    char *working_dir;
    FILE *fp;

    working_dir = calloc(PATH_SIZE, sizeof(char));

    fp = popen("pwd", "r");
    if (fp == NULL) {
        exit_with_error("failed to run pwd");
    }
    fgets(working_dir, PATH_SIZE, fp);
    pclose(fp);

    return working_dir;
}

bookmark *add_bookmark(char *name, char *path) {
    bookmark *b;

    // create bookmark node
    b = malloc(sizeof(bookmark));
    strcpy(b->name, name);
    strcpy(b->path, path);
    b->next = NULL;

    // add bookmark to the list
    if (bookmarks == NULL) {
        bookmarks = b;
    } else {
        bookmark *p = bookmarks;

        // find the last but one node
        while (p->next != NULL) {
            p = p->next;
        }

        // add the node to the list
        p->next = b;
    }

    return b;
}

// find a bookmark in the list
bookmark *find_bookmark(char *name) {
    bookmark *p = bookmarks;

    while (p != NULL && strcmp(p->name, name) != 0) {
        p = p->next;
    }

    return p;
}

bookmark *new_bookmark(char *name, char *path) {
    bookmark *p;

    if ((p = find_bookmark(name)) != NULL) {
        strcpy(p->path, path);
    } else {
        p = add_bookmark(name, path);
    }

    return p;
}

void delete_bookmark(char *name) {
    bookmark *p = bookmarks, *d;

    if (strcmp(bookmarks->name, name) == 0) {
        d = bookmarks;
        bookmarks = bookmarks->next;
        free(d);
    } else {
        while (p->next != NULL && strcmp(p->next->name, name) != 0) {
            p = p->next;
        }

        if (p != NULL) {
            d = p->next;
            p->next = d->next;
            free(d);
        }
    }
}

void save_bookmarks() {
    FILE *f;
    bookmark *p = bookmarks;

    if ((f = fopen(bookmarks_filename, "w")) != NULL) {
        while (p != NULL) {
            fprintf(f, "%s\t%s\n", p->name, p->path);
            p = p->next;
        }
    } else {
        exit_with_error("can't open configuration file");
    }
}

void load_bookmarks() {
    FILE *f;
    char name[NAME_SIZE], path[PATH_SIZE];

    if ((f = fopen(bookmarks_filename, "r")) != NULL) {
        while (fscanf(f, "%s\t%s", name, path) != EOF) {
            add_bookmark(name, path);
        }
    } else {
        exit_with_error("can't open configuration file");
    }
}

void print_bookmarks() {
    bookmark *p = bookmarks;

    while (p != NULL) {
        printf("%s\t%s\n", p->name, p->path);
        p = p->next;
    }
}

int main(int argc, char *argv[]) {
    /*
    if (argc == 2) {

    } else { // wrong number of arguments
        print_usage();
        exit(1);
    }
    */

    // load_bookmarks();
    new_bookmark("ciao", "/ciao");
    new_bookmark("ariciao", "/ariciao");
    // save_bookmarks();
    print_bookmarks();
    delete_bookmark("ariciao");
    printf("---\n");
    print_bookmarks();
    return 0;
}
