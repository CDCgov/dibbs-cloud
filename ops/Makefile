# Makefile for az cli shortcuts

SHELL:=/bin/bash

# Overrideable arguments
DEPLOYED_COMMIT?=$(shell git show --abbrev=7 -s --pretty=%h)
RELEASE_TAG?=$(subst refs/tags/,,$(GITHUB_REF))
CURL_TIMEOUT?=20

# Internal target: check if we are currently logged in, so we get a friendly error if not
.be-logged-in:
	@if ! az account show >& /dev/null ; then echo "You must be logged in to the az command line"; exit 1; fi

# Internal target: check if the passed-in wildcard is a known environment name. Hard-coding them because let's be real here.
.valid-env-%:
	@case $* in dev|prod) ;; *) echo "$* is not a valid environment"; exit 1;; esac

api.tfvars: /dev/null
	echo "acr_image_tag=\"$(DEPLOYED_COMMIT)\"" > $@; \
	echo "deploy_workflow=\"${GITHUB_WORKFLOW}\"" >> $@; \
	if [[ "release" == "$(GITHUB_EVENT_NAME)" ]]; \
		then echo "deploy_tag=\"$(RELEASE_TAG)\"" >> $@;\
	fi; \
	echo "deploy_runnumber=${GITHUB_RUN_NUMBER}" >> $@; \
	echo "deploy_timestamp=\"$(shell date +%Y-%m-%dT%H:%M:%S%z) \"" >> $@; \
	echo "deploy_actor=\"$(GITHUB_ACTOR)\"" >> $@;

init-%: .valid-env-%
	terraform -chdir=$*/persistent init
	terraform -chdir=$* init

plan-%: .valid-env-% api.tfvars
	terraform -chdir=$*/persistent plan -lock-timeout=30m
	terraform -chdir=$* plan -var-file=../api.tfvars -lock-timeout=30m

deploy-%: .valid-env-% api.tfvars
	terraform -chdir=$*/persistent apply -auto-approve -lock-timeout=30m
	terraform -chdir=$* apply -auto-approve -var-file=../api.tfvars -lock-timeout=30m