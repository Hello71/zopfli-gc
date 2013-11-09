FLAGS := -Wall -Wextra -ansi -pedantic
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
LIBZOPFLI_OBJ := $(patsubst %.c,%.o,$(LIBZOPFLI_SRC))
ZOPFLIBIN_SRC := src/zopfli/zopfli_bin.c
ZOPFLIBIN_OBJ := $(patsubst %.c,%.o,$(ZOPFLIBIN_SRC))
LODEPNG_SRC := src/zopflipng/lodepng/lodepng.cpp src/zopflipng/lodepng/lodepng_util.cpp
LODEPNG_OBJ := $(patsubst %.cpp,%.o,$(LODEPNG_SRC))
ZOPFLIPNG_SRC := src/zopflipng/zopflipng_lib.cc src/zopflipng/zopflipng_bin.cc
ZOPFLIPNG_OBJ := $(patsubst %.cc,%.o,$(ZOPFLIPNG_SRC))

LIBZOPFLI := libzopfli.so.1.0.1
SONAME := libzopfli.so.1

all: zopfli zopflipng libzopfli.so $(SONAME)

# Zopfli shared library
libzopfli.so $(SONAME): $(LIBZOPFLI)
	ln -fs $< $@

$(LIBZOPFLI): $(LIBZOPFLI_OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -Wl,-soname,$(SONAME) -lm -o $@ $^

$(LIBZOPFLI_OBJ): %.o: %.c
	$(CC) $(CFLAGS) -fPIC -c -o $@ $<


# Zopfli binary
zopfli: $(ZOPFLIBIN_OBJ) libzopfli.so
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(ZOPFLIBIN_OBJ) -lzopfli -L.


# ZopfliPNG binary
zopflipng: $(ZOPFLIPNG_OBJ) $(LODEPNG_OBJ) libzopfli.so
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(ZOPFLIPNG_OBJ) $(LODEPNG_OBJ) -lzopfli -L.


# Remove all libraries and binaries
ALL := $(LIBZOPFLI_OBJ) $(ZOPFLIBIN_OBJ) $(LODEPNG_OBJ) $(ZOPFLIPNG_OBJ) \
       liblodepng.a zopflipng zopfli libzopfli.so $(SONAME) $(LIBZOPFLI)
clean:
	$(RM) $(ALL)


# install
install: all
	mkdir -p $(DESTDIR)$(bindir)
	install -m755 zopfli zopflipng $(DESTDIR)$(bindir)
	mkdir -p $(DESTDIR)$(libdir)
	install -m755 libzopfli.so $(SONAME) $(LIBZOPFLI) $(DESTDIR)$(libdir)
	mkdir -p $(DESTDIR)$(includedir)/zopfli
	install -m644 src/libzopfli/deflate.h src/libzopfli/zlib_container.h \
	src/libzopfli/zopfli.h src/libzopfli/katajainen.h src/libzopfli/tree.h \
	src/libzopfli/gzip_container.h src/libzopfli/cache.h \
	src/libzopfli/squeeze.h src/libzopfli/lz77.h \
	src/libzopfli/util.h src/libzopfli/blocksplitter.h \
	src/libzopfli/hash.h $(DESTDIR)$(includedir)/zopfli


.PHONY: clean install
