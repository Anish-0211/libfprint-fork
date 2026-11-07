BUILD ?= build
SETUP_OPTS ?= -Ddoc=false -Dgtk-examples=false -Dintrospection=false
DRIVER_SRC := libfprint/drivers/ft9366.c libfprint/drivers/ft9366-match.c libfprint/drivers/ft9366-match.h

.PHONY: all setup install-tools deps configure nuke build test format format-check lint scan asan valgrind check clean help

all: build

setup: install-tools
	$(MAKE) configure
	ninja -C $(BUILD)

install-tools:
	@pkgs=""; \
	for t in uncrustify:uncrustify cppcheck:cppcheck valgrind:valgrind scan-build:clang-tools umockdev-run:umockdev; do \
		cmd=$${t%%:*}; pkg=$${t##*:}; \
		command -v $$cmd >/dev/null || pkgs="$$pkgs $$pkg"; \
	done; \
	if [ -n "$$pkgs" ]; then \
		echo "Installing:$$pkgs (sudo will ask for your password)"; \
		sudo apt update && sudo apt install -y$$pkgs; \
	else \
		echo "All tools present."; \
	fi

deps:
	@missing=""; pkgs=""; \
	for t in uncrustify:uncrustify cppcheck:cppcheck valgrind:valgrind scan-build:clang-tools umockdev-run:umockdev; do \
		cmd=$${t%%:*}; pkg=$${t##*:}; \
		command -v $$cmd >/dev/null || { missing="$$missing $$cmd"; pkgs="$$pkgs $$pkg"; }; \
	done; \
	if [ -n "$$missing" ]; then \
		echo "Missing tools:$$missing"; \
		echo "Install them yourself with: sudo apt install$$pkgs"; \
	else \
		echo "All tools present."; \
	fi

configure:
	@if [ -d $(BUILD) ]; then meson setup --wipe $(BUILD) $(SETUP_OPTS); else meson setup $(BUILD) $(SETUP_OPTS); fi

nuke:
	rm -rf build build-fresh build-scan build-asan

build:
	@if [ -d $(BUILD) ] && ! grep -q '"source": "$(CURDIR)"' $(BUILD)/meson-info/meson-info.json 2>/dev/null; then \
		$(MAKE) configure; \
	elif [ ! -d $(BUILD) ]; then \
		$(MAKE) configure; \
	fi
	ninja -C $(BUILD)

test: build
	meson test -C $(BUILD) --print-errorlogs

format:
	@command -v uncrustify >/dev/null || { echo "uncrustify not found: install the "uncrustify" package"; exit 1; }
	./scripts/uncrustify.sh

format-check:
	@command -v uncrustify >/dev/null || { echo "uncrustify not found: install the "uncrustify" package"; exit 1; }
	./scripts/uncrustify.sh --check

lint:
	@command -v cppcheck >/dev/null || { echo "cppcheck not found: install the "cppcheck" package"; exit 1; }
	cppcheck --library=gtk --suppress=unknownMacro --suppress=unusedStructMember:libfprint/drivers/ft9366-match.h --enable=warning,style,performance --inline-suppr --error-exitcode=1 -I libfprint -I libfprint/drivers $(DRIVER_SRC)

scan:
	rm -rf build-scan
	.gitlab-ci/scan-build meson setup build-scan $(SETUP_OPTS)
	.gitlab-ci/scan-build ninja -C build-scan

asan:
	rm -rf build-asan
	meson setup build-asan $(SETUP_OPTS) -Db_sanitize=address,undefined -Db_lundef=false
	meson test -C build-asan --print-errorlogs

valgrind: build
	meson test -C $(BUILD) --wrapper="valgrind --error-exitcode=1 --leak-check=full --suppressions=$(CURDIR)/tests/libfprint.supp" --print-errorlogs

check: format-check lint test

clean:
	rm -rf $(BUILD) build-scan build-asan

help:
	@echo "setup  deps  nuke  build  test  format  format-check  lint  scan  asan  valgrind  check  clean"
