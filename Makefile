TOPDIR ?= $(CURDIR)/.rpmbuild

.PHONY: srpm clean

srpm:
	./make-srpm.sh

clean:
	rm -rf "$(TOPDIR)"
