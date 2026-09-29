# Tagging shared by the kernel images. A kernel Makefile sets IMAGE_NAME and
# TAGS (the short tags it publishes, e.g. "6.1 5.10") and then includes this
# file.
#
# Every build gets two tags: <short tag>-<BUILD_ID>, which is never
# overwritten once published, and <short tag>, which moves to the newest build.

HACK_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

BUILD_ID_FILE := out/build-id

# BUILD_ID identifies one build. It defaults to the UTC time the build
# started, and is resolved once so that every variant built by one make run
# carries the same value.
#
# make push is a separate run from make build, so without an explicit BUILD_ID
# it takes the value the build recorded, not the current time.
ifndef BUILD_ID
override BUILD_ID := $(shell date -u +%Y%m%d-%H%M)
PUSH_BUILD_ID = $(shell cat $(BUILD_ID_FILE) 2>/dev/null)
else
PUSH_BUILD_ID = $(BUILD_ID)
endif

GIT_REVISION := $(shell git rev-parse HEAD)
BUILD_CREATED := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)

# $(call image_tags,<short tag>)
image_tags = -t $(IMAGE_NAME):$(1)-$(BUILD_ID) -t $(IMAGE_NAME):$(1)

# $(call image_labels,<short tag>,<kernel version>)
# The kernel version is the linux-stable tag that was built, without the "v".
image_labels = \
	--label org.opencontainers.image.created=$(BUILD_CREATED) \
	--label org.opencontainers.image.revision=$(GIT_REVISION) \
	--label org.opencontainers.image.version=$(1)-$(BUILD_ID) \
	--label dev.liquidmetal.kernel.version=$(2)

# Goes last in the build recipe, once every variant has built.
define record_build_id
mkdir -p $(dir $(BUILD_ID_FILE))
echo $(BUILD_ID) > $(BUILD_ID_FILE)
endef

.PHONY: push
push:
	$(HACK_DIR)push-kernel-image.sh $(IMAGE_NAME) "$(PUSH_BUILD_ID)" $(TAGS)

# Leave the default goal to the Makefile that includes this file.
.DEFAULT_GOAL :=
