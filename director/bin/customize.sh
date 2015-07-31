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
  #Add PRV zone to cobbler dns management
  sed -ri /etc/cobbler/settings -e "s/^#?manage_forward_zones.*/manage_forward_zones: ['mgt.symphony.local','$PRVDOMAIN']/g"
  sed -ri /etc/cobbler/settings -e "s/^#?manage_reverse_zones.*/manage_reverse_zones: ['10.78','10.110']/g"
cat << EOF > /etc/cobbler/zone_templates/$PRVDOMAIN
\\\$TTL 300
@                       IN      SOA     \$cobbler_server. nobody.example.com. (
                                        \$serial   ; Serial
                                        600         ; Refresh
                                        1800         ; Retry
                                        604800       ; Expire
                                        300          ; TTL
                                        )

                        IN      NS      \$cobbler_server.


symphony-director        IN A    10.110.254.1
symphony-directory	 IN A    10.110.254.2
symphony-repo   IN A    10.110.254.3
symphony-monitor IN A    10.110.254.4
symphony-app    IN A    10.110.254.5

\$cname_record

\$host_record
EOF

cat << EOF > /etc/cobbler/zone_templates/10.110
\\\$TTL 300
@                       IN      SOA     \$cobbler_server. nobody.example.com. (
                                        \$serial   ; Serial
                                        600         ; Refresh
                                        1800         ; Retry
                                        604800       ; Expire
                                        300          ; TTL
                                        )

                        IN      NS      \$cobbler_server.

254.1   IN PTR   symphony-director.$PRVDOMAIN.;
254.2   IN PTR   symphony-directory.$PRVDOMAIN.;
254.3   IN PTR   symphony-repo.mgt.$PRVDOMAIN.;
254.4   IN PTR   symphony-monitor.$PRVDOMAIN;
254.5   IN PTR   symphony-app.$PRVDOMAIN;

\$cname_record

\$host_record
EOF

fi

echo "Restarting Cobbler.."
/bin/systemctl restart cobblerd.service
sleep 1
cobbler sync
