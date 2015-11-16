#!/bin/bash
################################################################################
# (c) Copyright 2007-2014 Alces Software Ltd                                   #
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

if ! [ -z "$PRVDOMAIN" ]; then
  REALM=`echo $DOMAIN | sed -e 's/\(.*\)/\U\1/'`
  echo -n "Enter Onetime Password to set for symphony appliance enrollment: "
  read PASSWORD
  ipa host-add symphony-controller.mgt.symphony.local
  ipa host-mod symphony-controller.mgt.symphony.local --password "$PASSWORD"
  ipa host-add symphony-gateway.mgt.symphony.local
  ipa host-mod symphony-gateway.mgt.symphony.local --password "$PASSWORD"
  ipa group-add cloudusers
  ipa hostgroup-add cloudnodes
  ipa hostgroup-add-member cloudnodes --hosts symphony-controller
  ipa hostgroup-add-member cloudnodes --hosts symphony-gateway
  ipa hbacrule-add cloudaccess
  ipa hbacrule-add-host cloudaccess --hostgroups cloudnodes
  ipa hbacrule-add-user cloudaccess --group cloudusers
  ipa hbacrule-add-service cloudaccess --hbacsvcs=sshd
  ipa hbacsvc-add openvpn-public
  ipa hbacrule-add-service cloudaccess --hbacsvcs=openvpn-public 
fi
