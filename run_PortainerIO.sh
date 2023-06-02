#!/bin/sh
# REF https://docs.portainer.io/start/install-ce/server/docker/linux

# check if portainer_data variable is set , or take default value.
export PORTAINER_DATA=${PORTAINER_DATA:-/opt/portainer}
# check if /opt/portainer is exist , or mkdir it.
if [ ! -d $PORTAINER_DATA ]; 
then
  mkdir -p $PORTAINER_DATA
else
    echo "$PORTAINER_DATA already exist"
fi

# check if docker volume portainer_data is exist , or create it.
docker volume ls | grep portainer_data
if [ $? -ne 0 ]; 
then
  docker volume create --name portainer_data
else
  echo "portainer_data volume already exist"
fi

# run portainer docker container
docker run --detach \
 -p 9000:9000 \
 -p 9443:9443 \
 -p 8000:8000 \
 --name portainer.io \
 -v /var/run/docker.sock:/var/run/docker.sock \
 -v portainer_data:/data \
 portainer/portainer-ce:latest

# check if portainer.io is running
docker ps | grep portainer.io
if [ $? -eq 0 ]; then
  echo "Portainer.io is running"
  # Update container portainer.io restart policy to unless-stop.
  docker update --restart=unless-stopped portainer.io
fi