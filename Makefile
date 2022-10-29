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
		funvas:$(VERSION) /bin/bash

docker-run:
	@docker run --rm -it \
		-v $(shell pwd)/export:/app/export \
		--user=root:root \
		--workdir /app \
		--name funvas_$(VERSION) \
		funvas:$(VERSION) /bin/bash -ci 'set -eux; \
			xvfb-run /app/funvas_rendering \
			&& convert export/animation/*.png gif:- \
			| gifsicle -O3 --delay=2 --multifile - > export/animation.gif'
