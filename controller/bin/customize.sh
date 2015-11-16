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
  echo -n "Enter IPA Enrollment password: "
  read PASSWORD
  yum -e 0 -y --config http://symphony-repo.mgt.symphony.local/configs/$tree/yum.conf --enablerepo epel install ipa-client ipa-client-install
  ipa-client-install --no-ntp --mkhomedir --no-ssh --no-sshd --force-join --realm="$REALM" --server="symphony-directory.mgt.symphony.local" -w "$PASSWORD" --domain="$DOMAIN" --unattended
fi
