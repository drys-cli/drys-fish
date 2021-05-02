PREFIX ?= /usr/local

install:
	install -Dm644 fish/vendor_completions.d/*.fish -t $(DESTDIR)/$(PREFIX)/share/fish/vendor_completions.d
