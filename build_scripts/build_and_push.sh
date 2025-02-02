#!/bin/bash

if [ -z "${1}" ]
then
	echo "Usage: $0 borg_version tag"
	exit 1
fi

if [ -z "${2}" ]
then
	echo "Usage: $0 borg_version tag"
	exit 1
fi

export DOCKER_CLI_EXPERIMENTAL=enabled

docker login 
# docker buildx build --platform linux/amd64,linux/386,linux/arm64,linux/ppc64le,linux/s390x,linux/arm/v7,linux/arm/v6 .  -t takigama/secured-borg-server:latest --push
# for some reason ppc64le is no longer functional
echo "docker buildx build --build-arg BORG_VERSION=$1 --platform linux/amd64,linux/386,linux/arm64,linux/s390x,linux/arm/v7,linux/arm/v6 .  -t takigama/secured-borg-server:$2 --push"
echo "are you sure (ctrl-c to stop)"
sleep 10

for i in linux/amd64 linux/386 linux/arm64 linux/s390x linux/arm/v7 linux/arm/v6
do
	echo "Building for platform $i"
	echo "are you sure (ctrl-c to stop)"
	sleep 10
	docker buildx build --build-arg BORG_VERSION=$1 --platform $i .  -t takigama/secured-borg-server:$2 --push
done
