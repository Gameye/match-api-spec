SHELL:=$(PREFIX)/bin/sh
TAG?=$(shell git describe --tags)
VERSION:=$(shell npx semver $(TAG))
PACKAGE_NAME:=match-api-spec

rebuild: clean build

build: \
	out/static/version.txt \
	out/static/openapi.yaml \
	out/static/openapi.json \
	out/static/index.html \
	out/npm/ \

clean:
	rm -rf out

out/static/version.txt:
	@mkdir --parents $(@D)
	echo $(VERSION) > $@

out/static/openapi.yaml: src/openapi.yaml
	@mkdir --parents $(@D)
	sed 's/0.0.0-local/$(VERSION)/' $< > $@

out/static/openapi.json: out/static/openapi.yaml
	@mkdir --parents $(@D)
	npx js-yaml $< > $@

out/static/index.html: out/static/openapi.yaml
	@mkdir --parents $(@D)
	npx --yes redoc-cli bundle $< --output $@

out/npm/: out/static/openapi.yaml
	npx --yes oas3ts-generator@0.8.1 package \
		--package-dir $@ \
		--package-name @gameye/$(PACKAGE_NAME) \
		--request-type application/json \
		--response-type text/plain \
		--response-type application/json \
		$<
	( cd $@ ; npm install )

.PHONY: \
	clean \
	build \
	rebuild \
