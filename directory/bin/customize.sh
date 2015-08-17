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
  echo -n "Enter SecureAdmin Password: "
  read PASSWORD
  ipa-server-install -a "$PASSWORD" --hostname symphony-directory.mgt.symphony.local --ip-address=10.110.254.2 -r "$REALM" -p "$PASSWORD" -n "$DOMAIN" --no-ntp  --setup-dns --forwarder='10.78.254.1' --reverse-zone='10.in-addr.arpa.' --ssh-trust-dns --unattended 
  kinit admin
  ipa dnszone-add $PRVDOMAIN --name-server symphony-directory.mgt.symphony.local.
  ipa dnsforwardzone-add $MGTDOMAIN. --forwarder 10.78.254.1 --forward-policy=only
  ipa dnsforwardzone-add $EXTRADOMAIN. --forwarder 10.78.254.1 --forward-policy=only
  ipa dnsrecord-add $DOMAIN. $PRVDOMAINHEADER --ns-rec=symphony-directory.mgt.symphony.local.
  ipa dnsrecord-add $DOMAIN symphony-director --a-ip-address=10.78.254.1
  ipa dnsrecord-add mgt.symphony.local symphony-director --a-ip-address=10.78.254.1
  ipa dnsrecord-add mgt.symphony.local symphony-repo --a-ip-address=10.78.254.3
  ipa dnsrecord-add mgt.symphony.local symphony-monitor --a-ip-address=10.78.254.4
  ipa dnsrecord-add mgt.symphony.local symphony-app --a-ip-address=10.78.254.5

  ipa dnsrecord-add 10.in-addr.arpa. 1.254.78 --ptr-hostname symphony-director.mgt.symphony.local.
  ipa dnsrecord-add 10.in-addr.arpa. 3.254.78 --ptr-hostname symphony-repo.mgt.symphony.local.
  ipa dnsrecord-add 10.in-addr.arpa. 4.254.78 --ptr-hostname symphony-monitor.mgt.symphony.local.
  ipa dnsrecord-add 10.in-addr.arpa. 5.254.78 --ptr-hostname symphony-app.mgt.symphony.local.

  ipa dnsrecord-add $DOMAIN. $EXTRADOMAINHEADER  --ns-rec=symphony-director
  ipa dnsrecord-add $DOMAIN. $MGTDOMAINHEADER --ns-rec=symphony-director
  ipa dnsrecord-add $PRVDOMAIN symphony-directory --a-ip-address=10.110.254.2
  ipa config-mod --defaultshell /bin/bash
  ipa config-mod --homedirectory /users
  ipa group-add ClusterUsers --desc="Generic Cluster Users"
  ipa group-add AdminUsers --desc="Admin Cluster Users"
  ipa config-mod --defaultgroup ClusterUsers
  ipa pwpolicy-mod --maxlife=999

  ipa user-add alces-cluster --first Alces --last Software --random
  ipa group-add-member AdminUsers --users alces-cluster

  ipa hbacrule-disable allow_all
  ipa hostgroup-add usernodes --desc "All nodes allowing standard user access"
  ipa hostgroup-add adminnodes --desc "All nodes allowing only admin user access"

  ipa hbacrule-add adminaccess --desc "Allow admin access to admin hosts"
  ipa hbacrule-add useraccess --desc "Allow user access to user hosts"
  ipa hbacrule-add-service adminaccess --hbacsvcs sshd
  ipa hbacrule-add-service useraccess --hbacsvcs sshd

  ipa hbacrule-add-user adminaccess --groups AdminUsers
  ipa hbacrule-add-user useraccess --groups ClusterUsers

  ipa hbacrule-add-host adminaccess --hostgroups adminnodes
  ipa hbacrule-add-host useraccess --hostgroups usernodes

  ipa sudorule-add --cmdcat=all All
  ipa sudorule-add-user --groups=adminusers All
  ipa sudorule-mod All --hostcat='all'
  ipa sudorule-add-option All --sudooption '!authenticate'
fi
