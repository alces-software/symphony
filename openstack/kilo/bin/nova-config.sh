#!/bin/bash

echo "Have you updated /var/lib/symphony/openstack/kilo/bin/vars with CLUSTER ADMINPASS" 
echo "Press any key to continue.."; read

. /var/lib/symphony/openstack/kilo/bin/vars

#Fixup Configs

nova/etc/nova/nova.conf:rabbit_password="%ADMINPASS%"
nova/etc/nova/nova.conf:admin_password="%ADMINPASS%"
nova/etc/nova/nova.conf:admin_password='%ADMINPASS%'
nova/etc/nova/nova.conf:connection="mysql://openstack:%ADMINPASS%@%CONTROLLER_IP%/nova"
nova/etc/neutron/neutron.conf:nova_admin_password="%ADMINPASS%"

sh /var/lib/symphony/openstack/kilo/bin/install.sh nova/etc/nova/nova.conf /etc/nova/nova.conf
sh /var/lib/symphony/openstack/kilo/bin/install.sh nova/etc/neutron/neutron.conf /etc/neutron/neutron.conf
