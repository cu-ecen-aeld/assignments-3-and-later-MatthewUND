# Makefile for writer.c, the subject of Assignment 2
#
# Generates an application for the native build platform
# when GNU make variable CROSS_COMPILE is not specified 
# on the make command line. When CROSS_COMPILE is specified 
# with aarch64-none-linux-gnu- (note the trailing -) the 
# Makefile does cross-compilation
#
CC = $(CROSS_COMPILE)gcc
CFLAGS = -Wall -g


writer: writer.o
	$(CC) $(CFLAGS) writer.o -o writer 

writer.o: writer.c
		$(CC) $(CFLAGS) -c writer.c -o writer.o

clean:
	rm -f *.o *out
