REGISTRY?=ghcr.io/liquidmetal-dev
IMAGE?=firecracker-kernel-k8s
IMAGE_NAME?=$(REGISTRY)/$(IMAGE)

build:
	docker build \
		-t $(IMAGE_NAME):6.1 \
		--build-arg KERNEL_VERSION=6.1 \
		--build-arg KERNEL_CONFIG=https://raw.githubusercontent.com/firecracker-microvm/firecracker/main/resources/guest_configs/microvm-kernel-ci-x86_64-6.1.config \
		.
	docker build \
		-t $(IMAGE_NAME):5.10 \
		--build-arg KERNEL_VERSION=5.10.199 \
		--build-arg KERNEL_CONFIG=https://raw.githubusercontent.com/firecracker-microvm/firecracker/afe0e5f6469f2d804643be0cc0cef53c9d1c4f5d/resources/guest_configs/microvm-kernel-ci-x86_64-5.10.config \
		.

push:
	docker push $(IMAGE_NAME):6.1
	docker push $(IMAGE_NAME):5.10