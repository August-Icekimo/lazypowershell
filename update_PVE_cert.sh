#!/bin/sh
# Stop nginx service and update certificate

# check nginx process were stop
if [ $(sudo systemctl is-active nginx.service) = "active" ]; 
then
  echo "Stopping nginx service 關閉nginx服務"
sudo systemctl stop nginx.service
fi

# update certificate
echo "Updating certificate 替換 NODE certificate"
sudo pvecm updatecerts --force
echo "Updating ACME certificate 替換 ACME certificate"
sudo pvenode acme cert renew --force

# start nginx service
echo "Starting nginx service 開始nginx服務"
sudo systemctl start nginx.service
