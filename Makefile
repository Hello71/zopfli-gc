FLAGS := -Wall -Wextra -ansi -pedantic -Isrc/libzopfli
CFLAGS += $(FLAGS)
CXXFLAGS += $(FLAGS)

prefix ?= /usr/local
exec_prefix ?= $(prefix)
bindir ?= $(exec_prefix)/bin
libdir ?= $(exec_prefix)/lib
includedir ?= $(prefix)/include

LIBZOPFLI_SRC := src/libzopfli/blocksplitter.c src/libzopfli/cache.c\
                 src/libzopfli/deflate.c src/libzopfli/gzip_container.c\
                 src/libzopfli/hash.c src/libzopfli/katajainen.c\
                 src/libzopfli/lz77.c src/libzopfli/squeeze.c\
                 src/libzopfli/tree.c src/libzopfli/util.c\
                 src/libzopfli/zlib_container.c src/libzopfli/zopfli_lib.c
LIBZOPFLI_OBJ := $(LIBZOPFLI_SRC:.c=.o)
ZOPFLIBIN_SRC := src/zopfli/zopfli_bin.c
ZOPFLIBIN_OBJ := $(ZOPFLIBIN_SRC:.c=.o)
LODEPNG_SRC := src/zopflipng/lodepng/lodepng.cpp src/zopflipng/lodepng/lodepng_util.cpp
LODEPNG_OBJ := $(LODEPNG_SRC:.cpp=.o)
ZOPFLIPNG_SRC := src/zopflipng/zopflipng_lib.cc src/zopflipng/zopflipng_bin.cc
ZOPFLIPNG_OBJ := $(ZOPFLIPNG_SRC:.cc=.o)

LIBZOPFLI := libzopfli.so.1.0.1
SONAME := libzopfli.so.1

TARGETS := zopflipng zopfli libzopfli.so $(SONAME) $(LIBZOPFLI)

all: $(TARGETS)

# Zopfli shared library
libzopfli.so $(SONAME): $(LIBZOPFLI)
	ln -fs $< $@

$(LIBZOPFLI): $(LIBZOPFLI_OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -Wl,-soname,$(SONAME) -o $@ $^ -lm

$(LIBZOPFLI_OBJ): %.o: %.c
	$(CC) $(CFLAGS) -fPIC -c -o $@ $<

clean:
	$(RM) $(LIBZOPFLI_OBJ) $(ZOPFLIBIN_OBJ) $(LODEPNG_OBJ) $(ZOPFLIPNG_OBJ) $(TARGETS)


# install
install: all
	mkdir -p $(DESTDIR)$(bindir)
	install -m755 zopfli zopflipng $(DESTDIR)$(bindir)
	mkdir -p $(DESTDIR)$(libdir)
	install -m755 $(LIBZOPFLI) $(DESTDIR)$(libdir)
	cp -d libzopfli.so $(SONAME) $(DESTDIR)$(libdir)
	mkdir -p $(DESTDIR)$(includedir)/zopfli
	install -m644 src/libzopfli/deflate.h src/libzopfli/zlib_container.h \
	src/libzopfli/zopfli.h src/libzopfli/katajainen.h src/libzopfli/tree.h \
	src/libzopfli/gzip_container.h src/libzopfli/cache.h \
	src/libzopfli/squeeze.h src/libzopfli/lz77.h \
	src/libzopfli/util.h src/libzopfli/blocksplitter.h \
	src/libzopfli/hash.h $(DESTDIR)$(includedir)/zopfli


.PHONY: clean install
