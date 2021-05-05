PREFIX ?= /usr/local

install:
	install -Dm644 fish/vendor_completions.d/*.fish -t $(DESTDIR)/$(PREFIX)/share/fish/vendor_completions.d
	install -Dm644 fish/vendor_functions.d/*.fish -t $(DESTDIR)/$(PREFIX)/share/fish/vendor_functions.d

pacman:
	@mkdir -p _build/pacman
	@cd _build/pacman/; 				\
	cp ../../PKGBUILD ./;               \
	makepkg --skipinteg -f
clean:
	rm -rf _build/
