#!/bin/bash

if [ -z "${1}" ]
then
	echo "Usage: $0 borg_version tag [platforms]"
	echo "	Default platforms are: linux/amd64,linux/386,linux/arm64,linux/s390x,linux/arm/v7,linux/arm/v6"
	exit 1
fi

if [ -z "${2}" ]
then
	echo "Usage: $0 borg_version tag [platforms]"
	echo "	Default platforms are: linux/amd64,linux/386,linux/arm64,linux/s390x,linux/arm/v7,linux/arm/v6"
	exit 1
fi

export DOCKER_CLI_EXPERIMENTAL=enabled

docker login 

# stuff that needs to be done to handle multi architecture builds
# docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3
# docker buildx create --name mybuilder
# docker buildx use mybuilder
# docker buildx inspect --bootstrap
# docker login
# docker buildx build --platform linux/amd64,linux/386,linux/arm64,linux/ppc64le,linux/s390x,linux/arm/v7,linux/arm/v6 .  -t takigama/secured-borg-server:latest --push
# for some reason ppc64le is no longer functional

PLATFORM="linux/amd64,linux/386,linux/arm64,linux/s390x,linux/arm/v7,linux/arm/v6"
if [ -z "${3}" ]
then
	echo "Using default platforms 'linux/amd64,linux/386,linux/arm64,linux/s390x,linux/arm/v7,linux/arm/v6' for this build"
else
	PLATFORM=$3
	echo "Using platforms '$PLATFORM' for this build"
fi

echo "docker buildx build --build-arg BORG_VERSION=$1 --platform $PLATFORM .  -t takigama/secured-borg-server:$2 --push"
echo "are you sure (ctrl-c to stop)"
sleep 10


echo "Building for platform $PLATFORM"
echo "are you sure (ctrl-c to stop)"
sleep 10
docker buildx build --build-arg BORG_VERSION=$1 --platform $PLATFORM .  -t takigama/secured-borg-server:$2 --push
