EMSCRIPTEN_ROOT=$(shell ./find_emscripten)
EMCONFIGURE=$(EMSCRIPTEN_ROOT)/emconfigure
EMCC=$(EMSCRIPTEN_ROOT)/emcc

SRCDIR=graphviz-src
INSTALLDIR=graphviz-install

INSTALLED_LIBS=$(addprefix $(INSTALLDIR)/lib/,libgvc.a libgraph.a libcdt.a)
# EXTRA_LIBS=$(addprefix $(SRCDIR)/lib/, \
# 	common/.libs/libcommon_C.a pathplan/.libs/libpathplan_C.a \
# 	)
PLUGINS=$(addprefix $(INSTALLDIR)/lib/graphviz/,libgvplugin_core.a libgvplugin_dot_layout.a libgvplugin_neato_layout.a)
INCLUDEDIR=$(INSTALLDIR)/include/graphviz

.PHONY: all clean cleanjs
all: graphviz.js

# Note that the order here is extremely important!
# Plugins must be linked before the libraries, otherwise dead code stripping will kill things
graphviz.js: graphviz-js-wrapper.c | $(INSTALLDIR)/lib
	EMCC_DEBUG=1 $(EMCC) -o $@ $< $(PLUGINS) $(INSTALLED_LIBS) -I$(INCLUDEDIR) -O1

$(INSTALLDIR)/lib: | $(SRCDIR)/Makefile $(INSTALLDIR)
	cd $(SRCDIR) && make -i && $(CC) lib/gvpr/mkdefs.c -o lib/gvpr/mkdefs && make
	cd $(SRCDIR)/lib && make install
	cd $(SRCDIR)/plugin && make install

# Need pipe | here to just look for presence, not how new directories are
$(SRCDIR)/Makefile: | $(SRCDIR) $(INSTALLDIR)
	cd $(SRCDIR) && CPATH=$(CURDIR)/sysinclude:${CPATH} $(EMCONFIGURE) ./configure \
		--enable-swig=no --enable-sharp=no --enable-go=no \
		--enable-io=no --enable-java=no --enable-lua=no \
		--enable-ocaml=no --enable-perl=no --enable-php=no \
		--enable-python=no --enable-r=no --enable-ruby=no \
		--enable-tcl=no \
		--without-tcl --without-x --without-expat --without-devil --without-Xpm \
		--without-Xaw --without-z --without-rsvg --without-ghostscript \
		--without-visio --without-pangocairo --without-lasi \
		--without-glitz --without-freetype2 --without-fontconfig \
		--without-gdk-pixbuf --without-gtk --without-gtkgl --without-gtkglext \
		--without-glade --without-ming --without-qt --without-quartz \
		--without-gdiplus --without-libgd --without-glut --without-iconv \
		--without-png --without-jpeg \
		--enable-static --enable-shared=no \
		--prefix=$(CURDIR)/$(INSTALLDIR)

$(INSTALLDIR):
	mkdir -p $(INSTALLDIR)

$(SRCDIR): graphviz-src.tar.gz
	mkdir -p $(SRCDIR)
	tar xjf graphviz-src.tar.gz -C $(SRCDIR) --strip=1

graphviz-src.tar.gz:
	curl "http://www.graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.28.0.tar.gz" -o graphviz-src.tar.gz

clean: cleanjs
	rm -rf $(SRCDIR)
	rm -rf $(INSTALLDIR)

cleanjs:
	rm -f graphviz.js
