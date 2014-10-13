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

. $SYMPHONY_HOME/etc/vars.sh


yum -e 0 -y --config http://symphony-repo/configs/$TREE/yum.conf --enablerepo epel --enablerepo puppet-base --enablerepo puppet-deps install puppet

cat << EOF > /etc/puppet/puppet.conf
[main]
vardir = /var/lib/puppet
logdir = /var/log/puppet
rundir = /var/run/puppet
ssldir = \$vardir/ssl
[agent]
pluginsync      = true
report          = false
ignoreschedules = true
daemon          = false
ca_server       = symphony-director
certname        = `hostname -s`
environment     = production
server          = symphony-director
EOF

systemctl enable puppet

#Generate puppet signing request (cobbler will sort out the rest)
/usr/bin/puppet agent --test --waitforcert 0 --server symphony-director --environment symphony

echo "==========================================================================="
echo "Please login to symphony-director and sign the certificate for this machine"
echo "# puppet cert sign `hostname -s`"
