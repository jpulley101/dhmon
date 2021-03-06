
TAG=$(shell git name-rev --tags --name-only $(shell git rev-parse HEAD))
VERSION=$(shell echo $(TAG) | grep -o 'v[0-9\.]*' \
				| sed -E 's/^v([0-9\.]+)/-N \1-1/')
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
TREE=$(shell test $(TAG) = undefined && echo $(BRANCH) || echo $(TAG))

distclean:

clean install all:
	(test $@ = clean && rm -f .coverage) || true
	make -C $(CURDIR)/deps/ $@
	make -C $(CURDIR)/src/ $@

test:
	coverage erase
	TESTBASE=$(CURDIR) make -C $(CURDIR)/src/ $@
	coverage combine
	coverage report -m

deb:
	echo Using $(TREE)
	git checkout $(TREE)
	cp debian/changelog debian/changelog.old
	rm -f ../dhmon_*.orig.tar.gz
	gbp dch --snapshot --auto --ignore-branch $(VERSION)
	gbp buildpackage --git-upstream-tree=$(TREE) --git-submodules \
		--git-ignore-new --git-ignore-branch --git-builder='debuild -i -I -us -uc'
	mv debian/changelog.old debian/changelog
