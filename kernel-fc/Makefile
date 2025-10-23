REGISTRY?=ghcr.io/liquidmetal-dev
IMAGE?=firecracker-kernel
IMAGE_NAME?=$(REGISTRY)/$(IMAGE)

OUT_DIR := out

$(OUT_DIR):
	mkdir -p $@

build: build-61 build-5-10 build-5-10-no-acpi

build-61: $(OUT_DIR)
	curl -L -o $(OUT_DIR)/microvm-kernel-ci-x86_64-6.1.config https://raw.githubusercontent.com/firecracker-microvm/firecracker/main/resources/guest_configs/microvm-kernel-ci-x86_64-6.1.config
	cat $(OUT_DIR)/microvm-kernel-ci-x86_64-6.1.config configs/additional-61.config > $(OUT_DIR)/6-1.config
	docker build \
		-t $(IMAGE_NAME):6.1 \
		--build-arg KERNEL_VERSION=6.1 \
		--build-arg KERNEL_CONFIG=$(OUT_DIR)/6-1.config \
		.

build-5-10: $(OUT_DIR)
	curl -L -o $(OUT_DIR)/microvm-kernel-ci-x86_64-5.10.config https://raw.githubusercontent.com/firecracker-microvm/firecracker/refs/heads/main/resources/guest_configs/microvm-kernel-ci-x86_64-5.10.config
	cp $(OUT_DIR)/microvm-kernel-ci-x86_64-5.10.config $(OUT_DIR)/5-10.config
	docker build \
		-t $(IMAGE_NAME):5.10 \
		--build-arg KERNEL_VERSION=5.10.245 \
		--build-arg KERNEL_CONFIG=$(OUT_DIR)/5-10.config \
		.

build-5-10-no-acpi: $(OUT_DIR)
	curl -L -o $(OUT_DIR)/microvm-kernel-ci-x86_64-5.10-no-acpi.config https://raw.githubusercontent.com/firecracker-microvm/firecracker/refs/heads/main/resources/guest_configs/microvm-kernel-ci-x86_64-5.10-no-acpi.config
	cp $(OUT_DIR)/microvm-kernel-ci-x86_64-5.10-no-acpi.config $(OUT_DIR)/5-10-no-acpi.config
	docker build \
		-t $(IMAGE_NAME):5.10-no-acpi \
		--build-arg KERNEL_VERSION=5.10.245 \
		--build-arg KERNEL_CONFIG=$(OUT_DIR)/5-10-no-acpi.config \
		.

push:
	docker push $(IMAGE_NAME):6.1
	docker push $(IMAGE_NAME):5.10
	docker push $(IMAGE_NAME):5.10-no-acpi