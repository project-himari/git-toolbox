#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <fcntl.h>
#include <unistd.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>

#define EXIT_ERR(msg) exit_err(__FILE__, __LINE__, msg)

// Global variables
extern Display *display;
extern Window window;

extern Time timestamp;

extern long max_req;
extern int NUM_TARGETS;

extern Atom null_atom; /* The NULL atom */
extern Atom text_atom; /* The TEXT atom */
extern Atom utf8_atom; /* The UTF8 atom */

extern struct stat in_statbuf;

extern int current_alloc;
extern int total_input;

typedef int HandleResult;
#define HANDLE_OK           0
#define HANDLE_ERR          (1<<0)
#define HANDLE_INCOMPLETE   (1<<1)
#define DID_DELETE          (1<<2)

void print_help(FILE* fd);
void exit_err (char* filename, int line, const char* msg);
unsigned char* initialise_read (unsigned char* read_buffer);
unsigned char* read_input (unsigned char* read_buffer);
void set_selection__daemon (Atom selection, unsigned char* sel);
void set_selection (Atom selection, unsigned char* sel);
HandleResult handle_string (Display *display, Window requestor, Atom property, unsigned char* sel, Atom selection, Time time);
HandleResult handle_utf8_string (Display *display, Window requestor, Atom property, unsigned char* sel, Atom selection, Time time);

