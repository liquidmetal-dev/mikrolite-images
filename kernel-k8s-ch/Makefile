REGISTRY?=ghcr.io/liquidmetal-dev
IMAGE?=cloudhypervisor-kernel-k8s
IMAGE_NAME?=$(REGISTRY)/$(IMAGE)

build:
	docker build \
		-t $(IMAGE_NAME):6.2 \
		--build-arg KERNEL_VERSION=6.2 \
		--build-arg KERNEL_CONFIG=https://raw.githubusercontent.com/cloud-hypervisor/cloud-hypervisor/v43.0/resources/linux-config-x86_64 \
		.

push:
	docker push $(IMAGE_NAME):6.2