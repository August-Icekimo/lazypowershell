#!/bin/sh
VMName="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
if [ "$VMName" = "showVM.sh" ]
then
  export VMName="win10-p"
fi
echo $VMName
if [ $(virsh list | grep $VMName | wc -l ) -eq "0" ]
then
  virsh start $VMName
else
  echo "VM started."
fi
virt-viewer --full-screen $VMName