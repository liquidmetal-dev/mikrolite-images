REGISTRY?=ghcr.io/liquidmetal-dev
IMAGE?=firecracker-kernel-k8s
IMAGE_NAME?=$(REGISTRY)/$(IMAGE)

OUT_DIR := out

# Firecracker release to pull the base guest configs from. Pinned for
# reproducibility (main is a moving target).
FIRECRACKER_REF ?= v1.16.1
GUEST_CONFIG_URL := https://raw.githubusercontent.com/firecracker-microvm/firecracker/$(FIRECRACKER_REF)/resources/guest_configs
# The 5.10 config is kept pinned to an older commit that still targets 5.10.199.
GUEST_CONFIG_URL_510 := https://raw.githubusercontent.com/firecracker-microvm/firecracker/afe0e5f6469f2d804643be0cc0cef53c9d1c4f5d/resources/guest_configs

$(OUT_DIR):
	mkdir -p $@

build: $(OUT_DIR)
	curl -fL -o $(OUT_DIR)/microvm-kernel-ci-x86_64-6.1.config $(GUEST_CONFIG_URL)/microvm-kernel-ci-x86_64-6.1.config
	docker build \
		-t $(IMAGE_NAME):6.1 \
		--build-arg KERNEL_VERSION=6.1 \
		--build-arg KERNEL_CONFIG=$(OUT_DIR)/microvm-kernel-ci-x86_64-6.1.config \
		--build-arg KERNEL_FRAGMENTS="additional-61.config k8s_additions.config erofs.config" \
		.

	curl -fL -o $(OUT_DIR)/microvm-kernel-ci-x86_64-5.10.config $(GUEST_CONFIG_URL_510)/microvm-kernel-ci-x86_64-5.10.config
	docker build \
		-t $(IMAGE_NAME):5.10 \
		--build-arg KERNEL_VERSION=5.10.199 \
		--build-arg KERNEL_CONFIG=$(OUT_DIR)/microvm-kernel-ci-x86_64-5.10.config \
		--build-arg KERNEL_FRAGMENTS="k8s_additions.config erofs.config" \
		.

push:
	docker push $(IMAGE_NAME):6.1
	docker push $(IMAGE_NAME):5.10
