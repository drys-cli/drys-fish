PREFIX ?= /usr/local

build:
	mkdir -p _build/fun _build/comp
	sed "s:\([a-zA-Z_]\+\)_\($$\|[^a-zA-Z_']\):__fish_tem_\1\2:g" fun/*.fish	> _build/fun/tem.fish
	sed "s:\([a-zA-Z_]\+\)_\($$\|[^a-zA-Z_']\):__fish_tem_\1\2:g" comp/*.fish 	> _build/comp/tem.fish

install: build
	install -Dm644 _build/fun/tem.fish -t $(DESTDIR)/$(PREFIX)/share/fish/vendor_functions.d/
	install -Dm644 _build/comp/tem.fish -t $(DESTDIR)/$(PREFIX)/share/fish/vendor_completions.d/

pacman:
	@mkdir -p _build/pacman
	@cd _build/pacman/; 				\
	cp ../../PKGBUILD ./;               \
	makepkg --skipinteg -f
clean:
	rm -rf _build/
