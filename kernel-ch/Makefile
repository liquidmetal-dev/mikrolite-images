REGISTRY?=ghcr.io/liquidmetal-dev
IMAGE?=cloudhypervisor-kernel
IMAGE_NAME?=$(REGISTRY)/$(IMAGE)

# The short tags this image is published under.
TAGS := 6.2 6.2-headers

include ../hack/kernel-image.mk

# Cloud Hypervisor release to take the base kernel config from. The config
# file is not on the main branch of that repository any more, so this has to
# name a release that still has it.
CLOUD_HYPERVISOR_REF ?= v43.0
KERNEL_CONFIG_URL := https://raw.githubusercontent.com/cloud-hypervisor/cloud-hypervisor/$(CLOUD_HYPERVISOR_REF)/resources/linux-config-x86_64

build:
	docker build \
	    --target kernel \
		$(call image_tags,6.2) \
		$(call image_labels,6.2,6.2) \
		--build-arg KERNEL_VERSION=6.2 \
		--build-arg KERNEL_CONFIG=$(KERNEL_CONFIG_URL) \
		--build-arg KERNEL_FRAGMENTS="erofs.config" \
		.

	docker build \
	    --target headers \
		$(call image_tags,6.2-headers) \
		$(call image_labels,6.2-headers,6.2) \
		--build-arg KERNEL_VERSION=6.2 \
		--build-arg KERNEL_CONFIG=$(KERNEL_CONFIG_URL) \
		--build-arg KERNEL_FRAGMENTS="erofs.config" \
		.

	$(record_build_id)
