REGISTRY?=ghcr.io/liquidmetal-dev
IMAGE?=cloudhypervisor-kernel
IMAGE_NAME?=$(REGISTRY)/$(IMAGE)

# Cloud Hypervisor release to take the base kernel config from. The config
# file is not on the main branch of that repository any more, so this has to
# name a release that still has it.
CLOUD_HYPERVISOR_REF ?= v43.0
KERNEL_CONFIG_URL := https://raw.githubusercontent.com/cloud-hypervisor/cloud-hypervisor/$(CLOUD_HYPERVISOR_REF)/resources/linux-config-x86_64

build:
	docker build \
	    --target kernel \
		-t $(IMAGE_NAME):6.2 \
		--build-arg KERNEL_VERSION=6.2 \
		--build-arg KERNEL_CONFIG=$(KERNEL_CONFIG_URL) \
		.

	docker build \
	    --target headers \
		-t $(IMAGE_NAME):6.2-headers \
		--build-arg KERNEL_VERSION=6.2 \
		--build-arg KERNEL_CONFIG=$(KERNEL_CONFIG_URL) \
		.

push:
	docker push $(IMAGE_NAME):6.2
	docker push $(IMAGE_NAME):6.2-headers
