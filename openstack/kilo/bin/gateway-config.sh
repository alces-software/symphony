#!/bin/bash

echo "Have you updated /var/lib/symphony/openstack/kilo/bin/vars with CLUSTER ADMINPASS" 
echo "Press any key to continue.."; read

. /var/lib/symphony/openstack/kilo/bin/vars

#Fixup Configs
sh /var/lib/symphony/openstack/kilo/bin/install.sh controller/etc/keystone/keystone.conf /etc/keystone/keystone.conf
sh /var/lib/symphony/openstack/kilo/bin/install.sh network/etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini
sh /var/lib/symphony/openstack/kilo/bin/install.sh network/etc/neutron/neutron.conf /etc/neutron/neutron.conf
sh /var/lib/symphony/openstack/kilo/bin/install.sh network/etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini

