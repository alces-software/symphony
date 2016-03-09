#!/bin/bash
################################################################################
# (c) Copyright 2007-2016 Alces Software Ltd                                   #
#                                                                              #
# Symphony Software Toolkit                                                    #
#                                                                              #
# This file/package is part of Symphony                                        #
#                                                                              #
# Symphony is free software: you can redistribute it and/or modify it under    #
# the terms of the GNU Affero General Public License as published by the Free  #
# Software Foundation, either version 3 of the License, or (at your option)    #
# any later version.                                                           #
#                                                                              #
# Symphony is distributed in the hope that it will be useful, but WITHOUT      #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License #
# for more details.                                                            #
#                                                                              #
# You should have received a copy of the GNU Affero General Public License     #
# along with Symphony.  If not, see <http://www.gnu.org/licenses/>.            #
#                                                                              #
# For more information on the Symphony Toolkit, please visit:                  #
# http://www.alces-software.org/symphony                                       #
#                                                                              #
################################################################################
SYMPHONY_HOME=/var/lib/symphony/
. $SYMPHONY_HOME/etc/symphony.cfg

if [ -z "$OS_PASSWORD" ]; then
  echo "OS_PASSWORD not set, please source a keystone rc file" >&2
  exit 1
fi


if ! [ -z "$PRVDOMAIN" ]; then
  export OS_TENANT_NAME=private
  export OS_USERNAME=prvadmin
  neutron net-create prv -- \
  --provider:network_type=flat \
  --provider:physical_network=physnet1
  neutron subnet-create --enable-dhcp prv 10.110.0.0/16 --allocation-pool start=10.110.253.1,end=10.110.253.254 --gateway 10.110.254.1 --dns=10.110.254.2 --host-route destination=169.254.169.254/32,nexthop=10.110.253.0 --name prv
  neutron router-create prv
  neutron port-create --fixed-ip subnet=private,ip_address=10.110.253.0 --name prvrouter prv
  neutron router-interface-add prv port=prvrouter

  neutron net-create build -- \
  --provider:network_type=flat \
  --provider:physical_network=physnet3
  neutron subnet-create --enable-dhcp build 10.78.0.0/16 --allocation-pool start=10.78.253.1,end=10.78.253.254 --gateway 10.78.254.1 --dns=10.78.254.1 --host-route destination=169.254.169.254/32,nexthop=10.78.253.0 --name build 
  neutron router-create build
  neutron port-create --fixed-ip subnet=build,ip_address=10.78.253.0 --name buildrouter build
  neutron router-interface-add build port=buildrouter

  neutron net-create mgt -- \
  --provider:network_type=flat \
  --provider:physical_network=physnet5
  neutron subnet-create --enable-dhcp mgt 10.111.0.0/16 --allocation-pool start=10.111.253.1,end=10.111.253.254 --gateway 10.111.254.1 --dns=10.111.254.1 --host-route destination=169.254.169.254/32,nexthop=10.111.253.0 --name mgt
  neutron router-create mgt
  neutron port-create --fixed-ip subnet=mgt,ip_address=10.111.253.0 --name mgtrouter mgt
  neutron router-interface-add mgt port=mgtrouter
fi
