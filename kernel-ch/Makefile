REGISTRY?=ghcr.io/liquidmetal-dev
IMAGE?=cloudhypervisor-kernel
IMAGE_NAME?=$(REGISTRY)/$(IMAGE)

build:
	docker build \
	    --target kernel \
		-t $(IMAGE_NAME):6.2 \
		--build-arg KERNEL_VERSION=6.2 \
		--build-arg KERNEL_CONFIG=https://raw.githubusercontent.com/cloud-hypervisor/cloud-hypervisor/main/resources/linux-config-x86_64 \
		.

	docker build \
	    --target headers \
		-t $(IMAGE_NAME):6.2-headers \
		--build-arg KERNEL_VERSION=6.2 \
		--build-arg KERNEL_CONFIG=https://raw.githubusercontent.com/cloud-hypervisor/cloud-hypervisor/main/resources/linux-config-x86_64 \
		.

push:
	docker push $(IMAGE_NAME):6.2
	docker push $(IMAGE_NAME):6.2-headers