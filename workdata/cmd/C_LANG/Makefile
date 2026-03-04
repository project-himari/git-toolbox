CC := gcc

SRC := tclip.c
SRC += help.c
SRC += error.c
SRC += init_read.c
SRC += read_input.c
SRC += set_daemon.c
SRC += set_selection.c
SRC += handles.c

CFLAGS := -g -Wall -Wextra -Wshadow -Werror
LIBS := -lX11

tclip: ${SRC:.c=.o}
	${CC} ${CFLAGS} -o $@ $^ ${LIBS}

.c.o:
	${CC} -c -o $@ ${CLFAGS} $<

clean:
	rm -rf *.o tclip

