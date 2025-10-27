## OCM

OCM_VERSION_RAW=$(shell git describe --tags --always --dirty --match 'ocm-*')
OCM_VERSION=$(patsubst ocm-%,%,$(OCM_VERSION_RAW))

print-ocm-version: ## Print the OCM version
	@echo "0.0.1"
# 	@echo $(OCM_VERSION)

DOMAIN?="opendesk.example.com"
ENV?=dev
NAMESPACE?=default

# Run helmfile write-values and generate values.yaml files
.PHONY: values
values:
	DOMAIN=$(DOMAIN) cd opendesk-helmfiles && helmfile write-values -e $(ENV) -n $(NAMESPACE) --output-file-template "out/{{ .Release.Name}}.yaml"

# Package all configmaps from helmfile/apps/
.PHONY: configmaps
configmaps:
	mkdir -p out;
	@echo "Generating ConfigMaps..."
	@for app_path in opendesk-helmfiles/helmfile/apps/* ; do \
		if [ -d "$$app_path/out" ]; then \
			app_name=$$(basename $$app_path); \
			for f in $$app_path/out/*.yaml; do \
				[ -e "$$f" ] || continue; \
				file_name=$$(basename $$f .yaml); \
				cm_name=$$(echo "$${app_name}_$${file_name}_config_map" | sed "s/_/-/g"); \
				echo "Generating $$cm_name.yaml from $$f [$$(wc -c $$f)]"; \
				cp $$f values.yaml; \
				kubectl create configmap $$cm_name \
					--from-file=values.yaml \
					--dry-run=client -o=yaml > ocm/values-config-maps/$$cm_name.yaml; \
				rm values.yaml; \
			done \
		fi \
	done

clean:
	@echo "Cleaning temporary files..."
	@for app_path in opendesk-helmfiles/helmfile/apps/* ; do \
		if [ -d "$$app_path/out" ]; then \
			echo "Cleaning $$app_path/out..."; \
			rm -rf $$app_path/out; \
		fi \
	done

# Run everything: write values and package into ConfigMaps
.PHONY: all
all: values configmaps