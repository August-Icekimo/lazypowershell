#!/bin/sh
export VMName=win10-p
if [ $(virsh list | grep $VMName | wc -l ) -eq "0" ]
then
  virsh start $VMName
else
  echo "VM started."
fi
virt-viewer --full-screen $VMName