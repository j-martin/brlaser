# Convenience wrapper around the CMake build.
#
#   make                 configure and build in $(BUILD_DIR)
#   make check           build and run the tests
#   sudo make install    build (as the invoking user) and install
#   make clean           remove the build directory

BUILD_DIR ?= build
CMAKE ?= cmake
CMAKE_FLAGS ?=

# Under sudo, compile as the invoking user so the build tree is not left
# owned by root; only the actual install step needs root privileges.
ifeq ($(shell id -u),0)
ifdef SUDO_USER
AS_USER := sudo -u $(SUDO_USER) -- env PATH="$(PATH)"
endif
endif

.PHONY: all build check install clean

all: build

$(BUILD_DIR)/CMakeCache.txt:
	$(CMAKE) -S . -B $(BUILD_DIR) $(CMAKE_FLAGS)

build: $(BUILD_DIR)/CMakeCache.txt
	$(CMAKE) --build $(BUILD_DIR)

check: build
	$(CMAKE) --build $(BUILD_DIR) --target check

install:
ifdef AS_USER
	@if [ -d $(BUILD_DIR) ]; then chown -R $(SUDO_UID):$(SUDO_GID) $(BUILD_DIR); fi
	@echo "Building as $(SUDO_USER)"
endif
	@$(AS_USER) $(MAKE) build BUILD_DIR="$(BUILD_DIR)" CMAKE="$(CMAKE)" CMAKE_FLAGS="$(CMAKE_FLAGS)"
	$(CMAKE) --install $(BUILD_DIR)
ifdef AS_USER
	chown -R $(SUDO_UID):$(SUDO_GID) $(BUILD_DIR)
endif

clean:
	rm -rf $(BUILD_DIR)
