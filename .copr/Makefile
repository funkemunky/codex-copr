.PHONY: srpm

outdir ?= $(CURDIR)/.rpmbuild/SRPMS

srpm:
	mkdir -p "$(outdir)"
	rpkg srpm --outdir "$(outdir)"
