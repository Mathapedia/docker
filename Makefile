# Image name and version tag
IMAGE_NAME := mathapedia/latex
TAG        := $(shell git describe --tags --always 2>/dev/null || echo dev)
PLATFORMS  := linux/amd64,linux/arm64

# Legacy Docker Hub name (kept for existing consumers)
LEGACY_IMAGE := pyramation/pstricks-latex

# Image ref used by the run targets (ssh/tex/pstricks/check)
RUN_IMAGE ?= $(IMAGE_NAME):latest

# Default: build the image and compile the test document with it
def: build pstricks

# Build the image locally (single platform, loaded into the docker daemon)
build:
	docker build -t $(IMAGE_NAME):$(TAG) -t $(IMAGE_NAME):latest ./latex

# Multi-arch build + push (needs `docker buildx`; CI does this on tags)
buildx:
	docker buildx build --platform $(PLATFORMS) \
		-t $(IMAGE_NAME):$(TAG) -t $(IMAGE_NAME):latest --push ./latex

# Push the locally built image
push:
	docker push $(IMAGE_NAME):$(TAG)
	docker push $(IMAGE_NAME):latest

# Also tag/push under the legacy Docker Hub name
push-legacy:
	docker tag $(IMAGE_NAME):latest $(LEGACY_IMAGE):latest
	docker push $(LEGACY_IMAGE):latest

# Open an interactive shell in the container with ./tex mounted
ssh:
	docker run --rm -it -v `pwd`/tex:/usr/src $(RUN_IMAGE) /bin/bash

# Compile a plain document with pdflatex (test.tex itself needs the PSTricks route)
tex:
	docker run --rm -v `pwd`/tex:/usr/src $(RUN_IMAGE) \
		latexmk -pdf -interaction=nonstopmode -halt-on-error test.tex

# Compile the test document via latex -> dvips -> ps2pdf (PSTricks route)
pstricks:
	docker run --rm -v `pwd`/tex:/usr/src $(RUN_IMAGE) \
		latexmk -pdfps -interaction=nonstopmode -halt-on-error test.tex

# Smoke test: every tool the Mathapedia boilerplate relies on must be present
check:
	docker run --rm $(RUN_IMAGE) sh -c '\
		set -e; \
		for t in latex pdflatex dvips ps2pdf latexmk bibtex biber chktex latexindent dvisvgm gs node; do \
			command -v $$t >/dev/null || { echo "missing: $$t"; exit 1; }; \
		done; \
		for f in pstricks.sty pst-plot.sty tikz.sty pgfplots.sty cleveref.sty IEEEtran.bst; do \
			kpsewhich $$f >/dev/null || { echo "missing: $$f"; exit 1; }; \
		done; \
		echo ok'

# Clean LaTeX auxiliary files
clean-latex:
	docker run --rm -v `pwd`/tex:/usr/src $(RUN_IMAGE) latexmk -C test.tex

# Remove local images
clean-images:
	-docker rmi $(IMAGE_NAME):$(TAG) $(IMAGE_NAME):latest

.PHONY: def build buildx push push-legacy ssh tex pstricks check clean-latex clean-images
