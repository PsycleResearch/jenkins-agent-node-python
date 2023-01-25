REGISTRY := public.ecr.aws/psycle
REPOSITORY := jenkins-agent-node-python
TAG ?= latest

FULL_IMAGE_NAME = $(REGISTRY)/$(REPOSITORY):$(TAG)

all: image docker_login_aws push

docker_login_aws:
	@echo "Logging into docker using local awscli."
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws

image:
	docker build -t $(FULL_IMAGE_NAME) .

push:
	docker push $(FULL_IMAGE_NAME)


.PHONY: all docker_login_aws image push