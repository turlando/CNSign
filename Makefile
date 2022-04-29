DOCKER=docker
DEVICE=nonexistent
SHARED=./shared

.PHONY: build
build:
	$(DOCKER) build -t cnsign .

.PHONY: run
run:
	$(DOCKER) run            \
	    --rm                 \
	    --name cnsign        \
	    --device=$(DEVICE)   \
	    -v $(SHARED):/shared  \
	    -it                  \
	    cnsign
