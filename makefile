# Makefile for the libtls-openbsd package

MULI_TAG?=1.0
OPENBGPD_VERSION=6.7p0
ARCH=`dpkg --print-architecture`
DESTDIR=$(shell pwd)/debian/tmp
ACLOCAL?=aclocal
LIBTOOLIZE?=libtoolize
AUTOMAKE?=automake
AUTOCONF?=autoconf

debian: makefile debian/control $(OPENBGPD_VERSION).tar.gz
	rm -rf debian/tmp
	mkdir -p debian/tmp/DEBIAN
	mkdir -p debian/tmp/usr/local/bin
	mkdir -p debian/tmp/usr/local/include
	mkdir -p debian/tmp/usr/local/lib
	cd openbgpd-portable-$(OPENBGPD_VERSION); \
	/bin/sh autogen.sh ;\
	$(ACLOCAL) ; \
	$(LIBTOOLIZE) --copy --force ; \
	$(AUTOMAKE) --foreign --force-missing --add-missing --copy Makefile ; \
	$(AUTOMAKE) -a --copy ; \
	$(AUTOCONF) ; \
	/bin/sh configure --prefix=/usr/local --sysconfdir=/usr/local/etc --mandir=/usr/local/man --infodir=/usr/local/info --localstatedir=/var ; \
	make -j 2 -f Makefile ; \
	DESTDIR=${DESTDIR} make -f Makefile install

	# generate changelog from git log
	gbp dch --ignore-branch --git-author
	sed -i "/UNRELEASED;/s/unknown/${MULI_TAG}/" debian/changelog
	# generate dependencies
	dpkg-shlibdeps -ldebian/tmp/usr/local/lib debian/tmp/usr/local/sbin/*
	# generate symbols file
	dpkg-gensymbols
	# generate triggers file
	echo "activate-noawait ldconfig" > debian/tmp/DEBIAN/triggers
	# generate md5sums file
	find debian/tmp/ -type f -exec md5sum '{}' + | grep -v DEBIAN | sed s#debian/tmp/## > debian/tmp/DEBIAN/md5sums
	# control
	dpkg-gencontrol -v${OPENBGPD_VERSION}-${MULI_TAG}

	fakeroot dpkg-deb --build debian/tmp .

$(OPENBGPD_VERSION).tar.gz:
	wget -c https://github.com/openbgpd-portable/openbgpd-portable/archive/$(OPENBGPD_VERSION).tar.gz
	tar -xzvf $(OPENBGPD_VERSION).tar.gz

clean:
	rm -f *~ *.deb *.tar.gz
	rm -rf debian/tmp openbgpd-portable-*

.DEFAULT:
	make -f Makefile $@

.PHONY: clean debian

