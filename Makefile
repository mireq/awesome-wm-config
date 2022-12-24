CPPFLAGS=-Wall -Wextra -std=c++11 $(shell pkg-config libpulse --cflags --libs)


pulsectrl: pulsectrl.cpp Makefile
	$(CXX) $(CPPFLAGS) $< -o $@
	strip $@
