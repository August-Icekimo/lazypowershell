# Ref https://www.jenkins.io/doc/book/installing/docker/
# 依據Jenkins.io的安裝文件轉化而成
# 可使用參數設定儲存的路徑
# test if variable DOCKER_TLS_CERTDIR_PATH exists, or use the default value.
export DOCKER_TLS_CERTDIR_PATH="${DOCKER_TLS_CERTDIR_PATH:-/certs}"
# test if variable jenkinsCertsVol exists, or use the default value.
export jenkinsCertsVol="${jenkinsCertsVol:-/certs/client}"
# test if variable jenkinsDataVol exists, or use the default value.
export jenkinsDataVol="${jenkinsDataVol:-/var/jenkins_home}"

# Create folders for the very first day.
if [ $(docker volume ls | grep jenkins | wc -l ) -gt 0 ];
then 
  echo "Step 0.1: Jenkins Requried volume Ready 已確認所需的儲存區存在"
else
  docker volume create jenkins-data
  docker volume create jenkins-docker-certs
fi

# Create a bridge network in Docker named "jenkins"
if [ $(docker network ls | grep jenkins | wc -l ) -gt 0 ];
then 
  echo "Step 0.2: Jenkins Network Ready 已確認所需的網路段jenkins存在"
else
  docker network create jenkins
fi

# Run the jenkins docker for first step
echo "Step 1: Start Jenkins Docker IN Docker. 啟動容器與DIND"
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=$DOCKER_TLS_CERTDIR_PATH \
  --volume jenkins-docker-certs:$jenkinsCertsVol \
  --volume jenkins-data:$jenkinsDataVol \
  --publish 2376:2376 docker:dind
# Change jenkins-docker container to non-stop service
# https://stackoverflow.com/questions/54976581/how-to-update-restart-policy-of-docker-container
# if previous step return 0, then change to "unless-stopped"
if [ $? -eq 0 ]; 
then
  docker update --restart=unless-stopped jenkins-docker
else
  echo "Jenkins Docker IN Docker Failed, Please Check. Jenkins容器/DIND啟動失敗"
fi


# Reserve block for Homebrew jenkins LTS + blueocean
# https://hub.docker.com/repository/docker/icekimo/jenkins/general
# No autobuild , due to dockerhub "一夜1次郎" policy.
# docker hub build policy limited to one build per day.

echo "Step 2: Start Jenkins BlueOcean Official.啟動官方藍海BlueOcean"
docker run --name jenkins-blueocean --rm --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=$DOCKER_TLS_CERTDIR_PATH --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:$jenkinsDataVol \
  --volume jenkins-docker-certs:$jenkinsCertsVol:ro \
  jenkins/jenkins:lts-jdk11

# if container jenkins-blueocean return 0, then change to "unless-stopped"
if [ $? -eq 0 ];
then
  docker update --restart=unless-stopped jenkins-blueocean
fi

# Post Install Refs
echo "請參考官方安裝完畢後指南進行下一步"
echo "https://www.jenkins.io/doc/book/installing/docker/#post-installation"