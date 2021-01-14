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
	npx redoc-cli bundle $< --output $@

out/npm/: out/static/openapi.yaml
	npx oas3ts-generator@0.3.2 client \
		--request-type application/json \
		--package-dir $@ \
		--package-name @gameye/$(PACKAGE_NAME) \
		$<
	( cd $@ ; npm install )

.PHONY: \
	clean \
	build \
	rebuild \
