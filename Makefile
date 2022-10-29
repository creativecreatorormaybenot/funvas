export VERSION=0.1.7

docker-build:
	@docker build --compress \
		 --file ./Dockerfile \
		 --build-arg FLUTTER_VERSION=stable \
		 --tag funvas:$(VERSION) .

docker-shell:
	@docker run --rm -it \
		--workdir /app \
		--user=root:root \
		--name funvas_$(VERSION) \
		--net=host \
		funvas:$(VERSION) /bin/bash