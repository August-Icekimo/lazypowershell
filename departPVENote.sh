#!/bin/sh
echo "Run on the leaving node."
service pve-cluster stop
service corosync stop 
pmxcfs -l
rm -rf /etc/corosync/*
rm /etc/pve/corosync.conf
killall pmxcfs
service pve-cluster start 
service pveproxy restart
echo "vi /etc/pve/priv/known_hosts Kill others"
#pvecm delnode $hostname