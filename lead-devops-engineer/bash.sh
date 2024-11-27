#!/bin/bash

n=0;
while [[ "$n" -lt 60 ]] && ! docker stats --no-stream ; do
  n=$(( n + 1 )) ; sleep 1
  echo `expr 60 - $n`
done

cat <<EOF > env_vars.sh
ARTIFACTORY_PASSWORD="secret"
ARTIFACTORY_USERNAME="devops"
DOCKER_REPO="artifactory.docker.domain.name"
HELM_PASSWORD="secret"
HELM_REPO_URL="artifactory.helm.domain.name"
HELM_USERNAME="devops"
HELM_VIRTUAL_REPO_NAME="devops-helm-virtual"
IMAGE_NAME="python-app"
IMAGE_VERSION="v1.2.3"
PROJECT="devops"
EOF

source env_vars.sh

git clone https://gitlab.domain.name/${PROJECT}/$IMAGE_NAME -b develop
cd $IMAGE_NAME

docker login -u="${ARTIFACTORY_USERNAME}" -p"${ARTIFACTORY_PASSWORD}" ${DOCKER_REPO}
docker build . -t ${IMAGE_NAME}:$IMAGE_VERSION -t ${IMAGE_NAME}:latest

docker push ${DOCKER_REPO}/$PROJECT/${$IMAGE_NAME}:$IMAGE_VERSION
docker push ${DOCKER_REPO}/$PROJECT/$${$IMAGE_NAME}:latest

helm repo add ${HELM_VIRTUAL_REPO_NAME} ${HELM_REPO_URL}/$HELM_VIRTUAL_REPO_NAME \
--username ${HELM_USERNAME} --password ${HELM_PASSWORD}

helm repo update
helm dep up helm/$IMAGE_NAME
helm package --version ${IMAGE_VERSION} --app-version $IMAGE_VERSION helm/$IMAGE_NAME
