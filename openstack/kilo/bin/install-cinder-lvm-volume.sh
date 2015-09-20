#!/bin/bash

if ! ( vgdisplay cinder-volumes &> /dev/null ) ; then
  echo "Please create cinder-volumes VG before running this script" >&2 
  exit 1
fi

yum install -y openstack-cinder targetcli scsi-target-utils
/opt/admin/alces/kiloconfigs/bin/install.sh storage/etc/cinder/cinder.conf /etc/cinder/cinder.conf

systemctl start openstack-cinder-volume
systemctl enable openstack-cinder-volume
