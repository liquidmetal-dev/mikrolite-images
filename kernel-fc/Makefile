REGISTRY?=ghcr.io/liquidmetal-dev
IMAGE?=firecracker-kernel
IMAGE_NAME?=$(REGISTRY)/$(IMAGE)

OUT_DIR := out

$(OUT_DIR):
	mkdir -p $@

build: $(OUT_DIR)
	curl -L -o $(OUT_DIR)/microvm-kernel-ci-x86_64-6.1.config https://raw.githubusercontent.com/firecracker-microvm/firecracker/main/resources/guest_configs/microvm-kernel-ci-x86_64-6.1.config
	cat $(OUT_DIR)/microvm-kernel-ci-x86_64-6.1.config configs/additional-61.config > $(OUT_DIR)/6-1.config
	docker build \
		-t $(IMAGE_NAME):6.1 \
		--build-arg KERNEL_VERSION=6.1 \
		--build-arg KERNEL_CONFIG=$(OUT_DIR)/6-1.config \
		.

	curl -L -o $(OUT_DIR)/microvm-kernel-ci-x86_64-5.10.config https://raw.githubusercontent.com/firecracker-microvm/firecracker/afe0e5f6469f2d804643be0cc0cef53c9d1c4f5d/resources/guest_configs/microvm-kernel-ci-x86_64-5.10.config
	cp $(OUT_DIR)/microvm-kernel-ci-x86_64-5.10.config $(OUT_DIR)/5-10.config
	docker build \
		-t $(IMAGE_NAME):5.10 \
		--build-arg KERNEL_VERSION=5.10.199 \
		--build-arg KERNEL_CONFIG=$(OUT_DIR)/5-10.config \
		.

push:
	docker push $(IMAGE_NAME):6.1
	docker push $(IMAGE_NAME):5.10