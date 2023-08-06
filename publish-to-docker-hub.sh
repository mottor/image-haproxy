#!/bin/bash
CUR_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IMAGE_NAME="mottor1/haproxy"

#docker login ## Enter login and pass
export DOCKER_DEFAULT_PLATFORM=linux/amd64

while read -r line || [ -n "$line" ];
do
  echo " "
  echo "---------------"
  echo "Building $IMAGE_NAME:$line"
  docker build --build-arg HAPROXY_ORIG_VERSION="$line" --tag "$IMAGE_NAME:$line" .

  echo " "
  echo "---------------"
  echo "Pushing $IMAGE_NAME:$line"
  docker push "$IMAGE_NAME:$line"
done < $CUR_DIR/OFFICIAL_VERSIONS.md

echo " "
echo "✅ DONE"
echo " "
