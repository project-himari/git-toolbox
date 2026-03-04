#include "tclip.h"

#include <getopt.h>

Display *display;
Window window;

Time timestamp;
long max_req;

Atom null_atom; /* The NULL atom */
Atom text_atom; /* The TEXT atom */
Atom utf8_atom; /* The UTF8 atom */

int current_alloc = 0;
int total_input = 0;

// üÍfd=0, stdin
struct stat in_statbuf;

int main(int argc, char** argv) {
    int opt;
    int use_clipbard = 0;
    
    // ·¢IvVðè`
    struct option long_options[] = {
        {"help", no_argument, NULL, 'h'}, // help 
        {"clipboard", no_argument, NULL, 'b'}, // to windows
        {0, 0, 0, 0}
    };

    while ((opt = getopt_long(argc, argv, "h", long_options, NULL)) != -1) {
        switch (opt) {
            case 'h':
                print_help(stdout);
                exit(0); 
            case 'b':
                use_clipbard = 1;
            default:
                fprintf (stderr, "Error: Invalid option\n");
                fprintf (stderr, "\n");
                print_help(stderr);
                exit(1);
        }
    }
    
    Window root;
    Atom selection, test_atom;
    int black;
    XEvent event;
    
    unsigned char* new_sel = NULL;
    
    // stdinÉRÃ¯
    if (fstat (0, &in_statbuf) == -1)
        EXIT_ERR ("fstat error on stdin");

    if ((display = XOpenDisplay (NULL)) == NULL)
        EXIT_ERR ("Can't open display");
    
    root = XDefaultRootWindow (display);
    black = BlackPixel(display, DefaultScreen (display));
    window = XCreateSimpleWindow (display, root, 0, 0, 1, 1, 0, black, black);

    XStoreName (display, window, "tclip");

    XSelectInput (display, window, PropertyChangeMask);
    XChangeProperty (display, window, XA_WM_NAME, XA_STRING, 8, PropModeAppend, NULL, 0);
    while (1) {
        XNextEvent (display, &event);

        if (event.type == PropertyNotify)
        {
            timestamp = event.xproperty.time;
            break;
        }
    }
    
    // printf("timestamp: %lu \n", timestamp);

    max_req = 4000; // byte

    // test_atom = XInternAtom (display, "PRIMARY", False);
    // if (test_atom != XA_PRIMARY)
    //     fprintf (stderr, "XA_PRIMARY not named \"PRIMARY\"\n");

    text_atom       = XInternAtom (display, "TEXT", False);    
    utf8_atom       = XInternAtom (display, "UTF8_STRING", False);    
    null_atom       = XInternAtom (display, "NULL", False);
    
    if (use_clipbard)
        selection   = XInternAtom(display, "CLIPBOARD", False);
    else
        selection = XInternAtom (display, "PRIMARY", False);

    new_sel = initialise_read (new_sel);
    new_sel = read_input (new_sel);

    set_selection__daemon (selection, new_sel);
    
    exit (0);
}

