#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NAME_SIZE      64
#define PATH_SIZE     256
#define BOOKMARK_SIZE 321

char *bookmarks_filename = ".jumprc";

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
    printf("...usage...\n");
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

char *get_bookmarks_filepath() {
    char *homedir = getenv("HOME");
    char *bookmarks_filepath;
    int filepath_len = strlen(homedir) + strlen(bookmarks_filename) + 1;
    
    bookmarks_filepath = calloc(filepath_len, sizeof(char));
    strcpy(bookmarks_filepath, homedir);
    strcat(bookmarks_filepath, "/");
    strcat(bookmarks_filepath, bookmarks_filename);
    
    return bookmarks_filepath;
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
    bookmark *d;

    // the record is the first in the list
    if (bookmarks != NULL && strcmp(bookmarks->name, name) == 0) {
        d = bookmarks;
        bookmarks = bookmarks->next;
        free(d);
    } else {
        bookmark *p = bookmarks;
        
        // find the previous node
        while (p != NULL && p->next != NULL && strcmp(p->next->name, name) != 0) {
            p = p->next;
        }

        if (p->next != NULL) {
            d = p->next;
            p->next = d->next;
            free(d);
        } else {
            exit_with_error("no bookmark found");
        }
    }
}

void save_bookmarks() {
    FILE *f;
    bookmark *p = bookmarks;

    if ((f = fopen(get_bookmarks_filepath(), "w")) != NULL) {
        while (p != NULL) {
            fprintf(f, "%s\t%s\n", p->name, p->path);
            p = p->next;
        }
    } else {
        exit_with_error("can't save configuration file");
    }
}

void load_bookmarks() {
    FILE *f;
    char name[NAME_SIZE], path[PATH_SIZE];

    if ((f = fopen(get_bookmarks_filepath(), "r")) != NULL) {
        while (fscanf(f, "%s\t%s", name, path) != EOF) {
            add_bookmark(name, path);
        }
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
    if (argc == 2) {
        if(strcmp(argv[1], "list") == 0) {
            load_bookmarks();
            print_bookmarks();
        } else if(strcmp(argv[1], "help") == 0) {
            print_usage();
        } else {
            exit_with_error("wrong number of arguments.");
        }
    } else if (argc == 3) {
        if(strcmp(argv[1], "to") == 0) {
            load_bookmarks();
            printf("%s", find_bookmark(argv[2])->path);
        } else if(strcmp(argv[1], "add") == 0) {
            load_bookmarks();
            new_bookmark(argv[2], pwd());
            save_bookmarks();
        } else if(strcmp(argv[1], "del") == 0) {
            load_bookmarks();
            delete_bookmark(argv[2]);
            save_bookmarks();
        } else {
            exit_with_error("wrong number of arguments.");
        }
    } else { // wrong number of arguments
        print_usage();
        exit(1);
    }

    return 0;
}
