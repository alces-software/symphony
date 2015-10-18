#!/bin/bash

echo "Have you updated /var/lib/symphony/openstack/kilo/bin/vars with CLUSTER ADMINPASS" 
echo "Press any key to continue.."; read

. /var/lib/symphony/openstack/kilo/bin/vars

#Fixup Configs
sh /var/lib/symphony/openstack/kilo/bin/install.sh storage/etc/cinder/cinder.conf /etc/cinder/cinder.conf 
sh /var/lib/symphony/openstack/kilo/bin/install.sh storage/etc/glance/glance-api.conf /etc/glance/glance-api.conf
sh /var/lib/symphony/openstack/kilo/bin/install.sh storage/etc/glance/glance-registry.conf /etc/glance/glance-registry.conf
