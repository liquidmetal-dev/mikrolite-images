REGISTRY?=ghcr.io/liquidmetal-dev
IMAGE?=cloudhypervisor-kernel-k8s
IMAGE_NAME?=$(REGISTRY)/$(IMAGE)

# The short tags this image is published under.
TAGS := 6.2

include ../hack/kernel-image.mk

build:
	docker build \
		$(call image_tags,6.2) \
		$(call image_labels,6.2,6.2) \
		--build-arg KERNEL_VERSION=6.2 \
		--build-arg KERNEL_CONFIG=https://raw.githubusercontent.com/cloud-hypervisor/cloud-hypervisor/v43.0/resources/linux-config-x86_64 \
		.

	$(record_build_id)
