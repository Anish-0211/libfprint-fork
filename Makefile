BUILD ?= build
SETUP_OPTS ?= -Ddoc=false -Dgtk-examples=false -Dintrospection=false
DRIVER_SRC := libfprint/drivers/ft9366.c libfprint/drivers/ft9366-match.c libfprint/drivers/ft9366-match.h

.PHONY: all setup build test format format-check lint scan asan valgrind check clean help

all: build

setup:
	meson setup $(BUILD) $(SETUP_OPTS)

build:
	@if [ -d $(BUILD) ] && ! grep -q '"source": "$(CURDIR)"' $(BUILD)/meson-info/meson-info.json 2>/dev/null; then \
		meson setup --wipe $(BUILD) $(SETUP_OPTS); \
	elif [ ! -d $(BUILD) ]; then \
		$(MAKE) setup; \
	fi
	ninja -C $(BUILD)

test: build
	meson test -C $(BUILD) --print-errorlogs

format:
	@command -v uncrustify >/dev/null || { echo "uncrustify not found: sudo apt install uncrustify"; exit 1; }
	./scripts/uncrustify.sh

format-check:
	@command -v uncrustify >/dev/null || { echo "uncrustify not found: sudo apt install uncrustify"; exit 1; }
	./scripts/uncrustify.sh --check

lint:
	@command -v cppcheck >/dev/null || { echo "cppcheck not found: sudo apt install cppcheck"; exit 1; }
	cppcheck --enable=warning,style,performance --inline-suppr --error-exitcode=1 -I libfprint -I libfprint/drivers $(DRIVER_SRC)

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
	@echo "build  test  format  format-check  lint  scan  asan  valgrind  check  clean"
