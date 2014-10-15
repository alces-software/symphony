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

AVAILABLE_GROUPS="centos6.5 el6other centos7.0 el7other el7symphony"

GROUP=$1

if [ -z $GROUP ]; then
  echo "Please specify group, Available Groups: [$AVAILABLE_GROUPS]" >&2
  exit 1
fi

if ! [ -f /var/www/html/configs/ ]; then
  ln -snf $SYMPHONY_HOME/repo/yumconfigs /var/www/html/configs 
fi

case $GROUP in
  centos6.5) 
    #base
    pulp-admin rpm repo create --repo-id=centos6.5 --feed=http://www.mirrorservice.org/sites/mirror.centos.org/6.5/os/x86_64/ --serve-http=true --relative-url=centos/6.5/os/
    pulp-admin rpm repo sync run --repo-id centos6.5 --bg
    #updates
    pulp-admin rpm repo create --repo-id=centos6.5-updates --feed=http://www.mirrorservice.org/sites/mirror.centos.org/6.5/updates/x86_64/ --serve-http=true --relative-url=centos/6.5/updates
    pulp-admin rpm repo sync run --repo-id centos6.5-updates --bg
    cat $SYMPHONY_HOME/repo/yumconfigs/centos/6.5/yum-main.conf > $SYMPHONY_HOME/repo/yumconfigs/centos/6.5/yum.conf
    cat $SYMPHONY_HOME/repo/yumconfigs/centos/6.5/yum-repos.conf >> $SYMPHONY_HOME/repo/yumconfigs/centos/6.5/yum.conf
    ;;
  el6other)
    #epel
    pulp-admin rpm repo create --repo-id=epel6 --feed=http://anorien.csc.warwick.ac.uk/mirrors/epel/6/x86_64/ --serve-http=true --relative-url=epel6
    pulp-admin rpm repo sync run --bg --repo-id=epel6
    #cobbler
    pulp-admin rpm repo create --repo-id=cobbler-el6 --feed=http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-6/ --serve-http=true --relative-url=cobbler/el6
    pulp-admin rpm repo sync run --bg --repo-id=cobbler-el6
    #pulp
    pulp-admin rpm repo create --repo-id=pulp-el6 --feed=https://repos.fedorapeople.org/repos/pulp/pulp/stable/2/6Server/x86_64/ --serve-http=true --relative-url=pulp/el6
    pulp-admin rpm repo sync run --bg --repo-id=pulp-el6
    #puppet-deps
    pulp-admin rpm repo create --repo-id=puppet-deps-el6 --feed=https://yum.puppetlabs.com/el/6/dependencies/x86_64/ --serve-http=true --relative-url=puppet/deps/el6
    pulp-admin rpm repo sync run --bg --repo-id=puppet-deps-el6
    #puppet-base
    pulp-admin rpm repo create --repo-id=puppet-base-el6 --feed=https://yum.puppetlabs.com/el/6/products/x86_64 --serve-http=true --relative-url=puppet/base/el6
    pulp-admin rpm repo sync run --bg --repo-id=puppet-base-el6
    ;;
  centos7.0)
    #base
    pulp-admin rpm repo create --repo-id=centos7.0 --feed=http://www.mirrorservice.org/sites/mirror.centos.org/7.0.1406/os/x86_64/ --serve-http=true --relative-url=centos/7.0/os/
    pulp-admin rpm repo sync run --repo-id centos7.0 --bg
    #updates
    pulp-admin rpm repo create --repo-id=centos7.0-updates --feed=http://www.mirrorservice.org/sites/mirror.centos.org/7.0.1406/updates/x86_64/ --serve-http=true --relative-url=centos/7.0/updates
    pulp-admin rpm repo sync run --repo-id centos7.0-updates --bg
    cat $SYMPHONY_HOME/repo/yumconfigs/centos/7.0/yum-main.conf > $SYMPHONY_HOME/repo/yumconfigs/centos/7.0/yum.conf
    cat $SYMPHONY_HOME/repo/yumconfigs/centos/7.0/yum-repos.conf >> $SYMPHONY_HOME/repo/yumconfigs/centos/7.0/yum.conf
    ;;
  el7other)
    #epel
    pulp-admin rpm repo create --repo-id=epel7 --feed=http://anorien.csc.warwick.ac.uk/mirrors/epel/7/x86_64/ --serve-http=true --relative-url=epel7
    pulp-admin rpm repo sync run --bg --repo-id=epel7
    #cobbler
    pulp-admin rpm repo create --repo-id=cobbler-el7 --feed=http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-7/ --serve-http=true --relative-url=cobbler/el7
    pulp-admin rpm repo sync run --bg --repo-id=cobbler-el7
    #pulp
    pulp-admin rpm repo create --repo-id=pulp-el7 --feed=https://repos.fedorapeople.org/repos/pulp/pulp/stable/2/7Server/x86_64/ --serve-http=true --relative-url=pulp/el7
    pulp-admin rpm repo sync run --bg --repo-id=pulp-el7
    #puppet-deps
    pulp-admin rpm repo create --repo-id=puppet-deps-el7 --feed=https://yum.puppetlabs.com/el/7/dependencies/x86_64/ --serve-http=true --relative-url=puppet/deps/el7
    pulp-admin rpm repo sync run --bg --repo-id=puppet-deps-el7
    #puppet-base
    pulp-admin rpm repo create --repo-id=puppet-base-el7 --feed=https://yum.puppetlabs.com/el/7/products/x86_64 --serve-http=true --relative-url=puppet/base/el7
    pulp-admin rpm repo sync run --bg --repo-id=puppet-base-el7
    ;;
  el7symphony)
    pulp-admin rpm repo create --repo-id=symphony-el7 --feed=http://download.alces-software.com/repos/symphony/el7/ --serve-http=true --relative-url=symphony/el7
    pulp-admin rpm repo sync run --bg --repo-id=symphony-el7
    ;;
  *)
    echo "Unknown Group" >&2
    exit 1
    ;;
esac
