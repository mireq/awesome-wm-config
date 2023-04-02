.PHONY: all



pulsectrl: pulsectrl.cpp Makefile
	$(CXX) -Wall -Wextra -std=c++11 $(shell pkg-config libpulse --cflags --libs) $< -o $@
	strip $@


tools/softwarecursor-x11: software-cursor/softwarecursor-x11.c Makefile
	${CC} $< -o $@ -lX11 -lXfixes -lXi -lXext
	strip $@
