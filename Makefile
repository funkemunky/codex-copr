TOPDIR ?= $(CURDIR)/.rpmbuild
ARCH ?= x86_64

.PHONY: srpm srpm-x86_64 srpm-aarch64 clean

srpm:
	ARCH="$(ARCH)" TOPDIR="$(TOPDIR)" ./make-srpm.sh

srpm-x86_64:
	ARCH="x86_64" TOPDIR="$(TOPDIR)" ./make-srpm.sh

srpm-aarch64:
	ARCH="aarch64" TOPDIR="$(TOPDIR)" ./make-srpm.sh

clean:
	rm -rf "$(TOPDIR)"
