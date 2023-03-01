image_name := railsmin
DOCKERFILE_PROD := Dockerfile
RUBY_VERSION := 3.2.1-alpine
BUNDLER_VERSION := 2.2.3
RAILS_ENV := production
DOCKER_USER=godieboy
default: help

help: #: Show help topics
	@grep "#:" Makefile* | grep -v "@grep" | sort | sed "s/\([A-Za-z_ -]*\):.*#\(.*\)/$$(tput setaf 3)\1$$(tput sgr0)\2/g"

clean: #: delete extra folder and files 
	rm -rf .bundle vendor coverage
 
prod: #: build prod image
	docker build -t ${DOCKER_USER}/${image_name}:${RAILS_ENV} --build-arg RUBY_VERSION=$(RUBY_VERSION) --build-arg RAILS_ENV=${RAILS_ENV} --build-arg BUNDLER_VERSION=${BUNDLER_VERSION} --build-arg RAILS_SERVE_STATIC_FILES=true -f $(DOCKERFILE_PROD) .

run_prod: #: run prod container 
	docker run -p 3000:3000 ${DOCKER_USER}/${image_name}:${RAILS_ENV}

amd64: #: build for amd64
	docker buildx build --platform linux/amd64 -t ${DOCKER_USER}/${image_name}:${RAILS_ENV}_amd --build-arg RUBY_VERSION=$(RUBY_VERSION) --build-arg RAILS_ENV=${RAILS_ENV} --build-arg BUNDLER_VERSION=${BUNDLER_VERSION} --build-arg RAILS_SERVE_STATIC_FILES=true  -f $(DOCKERFILE_PROD) .
