.PHONY: srpm

outdir ?= $(CURDIR)/.rpmbuild/SRPMS
TOPDIR ?= $(CURDIR)/.rpmbuild

srpm:
	$(MAKE) -C "$(CURDIR)" srpm TOPDIR="$(TOPDIR)"
	mkdir -p "$(outdir)"
	cp "$(TOPDIR)"/SRPMS/*.src.rpm "$(outdir)"/
