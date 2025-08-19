# install docker-ce
 for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

 curl -fsSL https://get.docker.com -o get-docker.sh
 sudo sh ./get-docker.sh --dry-run
 sudo sh get-docker.sh

 sudo groupadd docker
 sudo usermod -aG docker $USER 

 # Uninstall Docker Engine
# sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extrasv
# sudo rm -rf /var/lib/docker
# sudo rm -rf /var/lib/containerd
# sudo rm /etc/apt/sources.list.d/docker.list
# sudo rm /etc/apt/keyrings/docker.asc

# REF:https://docs.docker.com/engine/install/ubuntu/
