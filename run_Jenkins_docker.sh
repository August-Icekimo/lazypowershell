# Ref https://www.jenkins.io/doc/book/installing/docker/

export DOCKER_TLS_CERTDIR_PATH="/certs"
export jenkinsCertsVol="/certs/client"
export jenkinsDataVol="/var/jenkins_home"
# Create folders for the very first day.
if [ $(docker volume ls | grep jenkins | wc -l ) -gt 0 ];
then 
  echo "Step 0.1: Jenkins Requried volume Ready"
else
  docker volume create jenkins-data
  docker volume create jenkins-docker-certs
fi

# Create a bridge network in Docker named "jenkins"
if [ $(docker network ls | grep jenkins | wc -l ) -gt 0 ];
then 
  echo "Step 0.2: Jenkins Network Ready"
else
  docker network create jenkins
fi

# Run the jenkins docker for first step
echo "Step 1: Start Jenkins Docker IN Docker."
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=$DOCKER_TLS_CERTDIR_PATH \
  --volume jenkins-docker-certs:$jenkinsCertsVol \
  --volume jenkins-data:$jenkinsDataVol \
  --publish 2376:2376 docker:dind
# Change jenkins-docker container to non-stop service
#docker update --restart unless-stopped jenkins-docker

# Homebrew jenkins LTS + blueocean
# https://hub.docker.com/repository/docker/icekimo/jenkins/general
# No autobuild , due to dockerhub "一夜兩次郎" polocy.
echo "Step 2: Start Jenkins BlueOcean."
docker run --name jenkins-blueocean --rm --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=$DOCKER_TLS_CERTDIR_PATH --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:$jenkinsDataVol \
  --volume jenkins-docker-certs:$jenkinsCertsVol:ro \
  icekimo/jenkins:latest

# Post Install 
# https://www.jenkins.io/doc/book/installing/docker/#setup-wizard