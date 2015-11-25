#!/bin/bash

echo "Have you updated /var/lib/symphony/openstack/kilo/bin/vars with CLUSTER ADMINPASS" 
echo "Press any key to continue.."; read

. /var/lib/symphony/openstack/kilo/bin/vars

#Fixup Configs
sh /var/lib/symphony/openstack/kilo/bin/install.sh nova/etc/nova/nova.conf /etc/nova/nova.conf
sh /var/lib/symphony/openstack/kilo/bin/install.sh nova/etc/neutron/neutron.conf /etc/neutron/neutron.conf
