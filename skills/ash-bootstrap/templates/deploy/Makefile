REGISTRY := <REGISTRY>
APP      := <APP>
GIT_SHA  := $(shell git rev-parse --short HEAD)
PLATFORM := linux/amd64
STACK    := deploy/stack.yml

.PHONY: build deploy check-clean

## The tree must be clean and pushed: an image tagged with a SHA that exists
## only on this machine cannot be reproduced or rolled back to.
check-clean:
	@test -z "$$(git status --porcelain)" || \
		{ echo "ERROR: Working tree is dirty. Commit or stash changes first."; exit 1; }
	@git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1 || \
		{ echo "ERROR: No upstream tracking branch. Push with -u first."; exit 1; }

## Build and push, tagged with the current SHA and latest
build: check-clean
	docker buildx build --platform $(PLATFORM) \
		-t $(REGISTRY)/$(APP):$(GIT_SHA) -t $(REGISTRY)/$(APP):latest \
		-f Dockerfile --push .

## Pin the stack to the built SHA and hand it to the deployer
deploy: build
	sed -i -E "s|($(REGISTRY)/$(APP)):[a-zA-Z0-9._-]+|\1:$(GIT_SHA)|" $(STACK)
	git add $(STACK)
	git commit -m "deploy: $(GIT_SHA)"
	git push
	# Deploying without a panel that watches this repository:
	#   DOCKER_HOST=ssh://<user>@<host> docker stack deploy -c $(STACK) $(APP)
