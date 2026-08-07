TOPDIR ?= $(CURDIR)/.rpmbuild
OUTDIR ?= $(TOPDIR)/SRPMS

.PHONY: srpm srpm-x86_64 srpm-aarch64 clean

srpm:
	mkdir -p "$(OUTDIR)"
	rpkg srpm --outdir "$(OUTDIR)"

srpm-x86_64: srpm

srpm-aarch64: srpm

clean:
	rm -rf "$(TOPDIR)" *.tar.gz codex.spec
