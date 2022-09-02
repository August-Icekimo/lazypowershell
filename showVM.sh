#!/bin/sh
# 
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

: <<'END_OF_DOCS'
=head1 NAME

Show or start KVM Virtual Machine by vmname, RUN ln to change basename

=head1 SYNOPSIS

  Copy this shellscript to /usr/local/bin, and
    ln -s /usr/local/bin/showVM.sh YourVMName
  then, you can type "YourVMName" to connect to it.

=head1 OPTIONS
  No Options.

=head1 DESCRIPTION

=head1 LICENSE AND COPYRIGHT

=cut

END_OF_DOCS