# Ref https://www.jenkins.io/doc/book/installing/docker/

export my_nvme="/srv/nvme/jenkins"
export DOCKER_TLS_CERTDIR_PATH="$my_nvme/certs"
export jenkinsCertsVol="$my_nvme/certs/client"
export jenkinsDataVol="$my_nvme/var/jenkins_home"
mkdir -p $DOCKER_TLS_CERTDIR_PATH
mkdir -p $jenkinsCertsVol
mkdir -p $jenkinsDataVol
# Create a bridge network in Docker named "jenkins"
docker network create jenkins

# Run the jenkins docker for first step
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=$DOCKER_TLS_CERTDIR_PATH \
  --volume jenkins-docker-certs:$jenkinsCertsVol \
  --volume jenkins-data:$jenkinsDataVol \
  --publish 2376:2376 docker:dind

# Homebrew jenkins LTS + blueocean
# https://hub.docker.com/repository/docker/icekimo/jenkins/general
# No autobuild , due to dockerhub "一夜兩次郎" polocy.
docker run --name jenkins-blueocean --rm --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=$DOCKER_TLS_CERTDIR_PATH --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:$jenkinsDataVol \
  --volume jenkins-docker-certs:$jenkinsCertsVol:ro \
  icekimo/jenkins:latest

# Post Install 
# https://www.jenkins.io/doc/book/installing/docker/#setup-wizard

# Change jenkins-docker container to non-stop service
docker update --restart unless-stopped jenkins-docker