# ----------------------------------------------------------------------------------------
#                                        Dockerfile
# ----------------------------------------------------------------------------------------

# AMD 64 only!

ARG FLUTTER_VERSION="stable"
ARG FLUTTER_HOME="/opt/flutter"
ARG PUB_CACHE="/var/tmp/.pub_cache"
ARG FLUTTER_URL="https://github.com/flutter/flutter"

# Download and install Flutter SDK with all dependencies.
FROM ubuntu:22.10 AS dependencies

USER root
WORKDIR /

ARG FLUTTER_VERSION
ARG FLUTTER_HOME
ARG PUB_CACHE
ARG FLUTTER_URL

# Environment variables
ENV FLUTTER_VERSION=$FLUTTER_VERSION \
    FLUTTER_HOME=$FLUTTER_HOME \
    FLUTTER_ROOT=$FLUTTER_HOME \
    PUB_CACHE=$PUB_CACHE \
    PATH="${PATH}:${FLUTTER_HOME}/bin:${PUB_CACHE}/bin"

# Install linux dependency, utils and flutter
RUN set -eux; mkdir -p /usr/lib /app $PUB_CACHE \
    # Install linux dependency
    && apt-get update -y && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends bash curl git ca-certificates \
    wget unzip iputils-ping wget zip unzip apt-transport-https gnupg locales make \
    clang cmake ninja-build pkg-config libgtk-3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Setup locale
    && locale-gen en_US "en_US.UTF-8" && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && git config --global user.email "flutter@gmail.com" \
    && git config --global user.name "Flutter" \
    && git config --global --add safe.directory "${FLUTTER_HOME}" \
    && git config --global credential.helper store \
    && echo 'alias "fvm"=""' >> ~/.bashrc \
    # Install flutter sdk
    && git clone -b ${FLUTTER_VERSION} --depth 1 "${FLUTTER_URL}.git" "${FLUTTER_ROOT}" \
    && cd "${FLUTTER_ROOT}" \
    && git gc --prune=all \
    && dart --disable-analytics \
    && flutter config --no-analytics --enable-linux-desktop \
    && flutter doctor \
    && flutter precache --universal --linux --no-android --no-ios --no-web --no-windows --no-macos --no-fuchsia

# Set locale to en_US
ENV LANG en_US.UTF-8

# Build the app
FROM dependencies AS builder

COPY . /app

RUN set -eux; cd /app/funvas_rendering \
    && flutter pub get \
    && flutter build linux --release

# Create new clean, production layer
FROM ubuntu:22.10 as production

# Copy dependencies
COPY --from=builder /app/funvas_rendering/build/linux/x64/release/bundle/ /app/

RUN set -eux; mkdir -p /usr/lib \
    # Install linux dependency
    && apt-get update -y && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends libgtk-3-0 libblkid1 liblzma5 locales \
    # Setup locale
    && locale-gen en_US "en_US.UTF-8" && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set locale to en_US
ENV LANG en_US.UTF-8

# Add lables
LABEL name="funvas" \
    description="Image for rendering and exporting funvas animations." \
    maintainer="Mikhail Matiunin <plugfox@gmail.com>" \
    group="flutter"

# Launch config by default
USER root
WORKDIR /app
SHELL [ "/bin/bash", "-c" ]
CMD [ "flutter", "doctor" ]