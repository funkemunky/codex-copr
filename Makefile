TOPDIR ?= $(CURDIR)/.rpmbuild

.PHONY: srpm srpm-x86_64 srpm-aarch64 clean

srpm:
	TOPDIR="$(TOPDIR)" ./make-srpm.sh

srpm-x86_64:
	TOPDIR="$(TOPDIR)" ./make-srpm.sh

srpm-aarch64:
	TOPDIR="$(TOPDIR)" ./make-srpm.sh

clean:
	rm -rf "$(TOPDIR)"
