REGISTRY?=ghcr.io/liquidmetal-dev
IMAGE_NAME?=$(REGISTRY)/ubuntu
TAG?=22.04

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

push:
	docker push $(IMAGE_NAME):$(TAG)
