INSTALLDIR = $(shell pwd)/library

LDFLAGS = -static -I$(INSTALLDIR)/include -L$(INSTALLDIR)/lib -lcrypto -ldl 
CFLAGS = -Wall -Wextra -Wl,-rpath,$(INSTALLDIR)/lib

all: OpenSSL.c
	$(CC) $(CFLAGS) OpenSSL.c -o OpenSSL-fips $(LDFLAGS)

clean:
	rm -f *.o $(BINS)
