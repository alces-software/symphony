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

AVAILABLE_GROUPS="centos6.5 el6other centos7.0 el7other el7symphonyi rhel6 rhelhpcnode6"

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
  rhel6)
    if [ -f /etc/pulp/rhel.pem ]; then 
      #base
      pulp-admin rpm repo create --repo-id=rhel6 --feed=https://cdn.redhat.com/content/dist/rhel/server/6/6Server/x86_64/os --serve-http=true --relative-url=rhel/6/os/ --feed-ca-cert=/etc/rhsm/ca/redhat-uep.pem --feed-cert=/etc/pulp/rhel.pem --feed-key=/etc/pulp/rhel.pem
      pulp-admin rpm repo sync run --repo-id rhel6 --bg
      #optional
      pulp-admin rpm repo create --repo-id=rhel6-optional --feed=https://cdn.redhat.com/content/dist/rhel/server/6/6Server/x86_64/optional/os --serve-http=true --relative-url=rhel/6/optional/ --feed-ca-cert=/etc/rhsm/ca/redhat-uep.pem --feed-cert=/etc/pulp/rhel.pem --feed-key=/etc/pulp/rhel.pem
      pulp-admin rpm repo sync run --repo-id rhel6-optional --bg
      cat $SYMPHONY_HOME/repo/yumconfigs/rhel/6/yum-main.conf > $SYMPHONY_HOME/repo/yumconfigs/rhel/6/yum.conf
      cat $SYMPHONY_HOME/repo/yumconfigs/rhel/6/yum-repos.conf >> $SYMPHONY_HOME/repo/yumconfigs/rhel/6/yum.conf
    else
      echo "Can't locate rhel server entitlement certificate (/etc/pulp/rhel.pem), please refer to symphony wiki" >&2
      exit 1
    fi
    ;;
  rhelhpcnode6)
    if [ -f /etc/pulp/rhel-hpcnode.pem ]; then
      #hpccomputenodebase
      pulp-admin rpm repo create --repo-id=rhelhpcnode6 --feed=https://cdn.redhat.com/content/dist/rhel/computenode/6/6ComputeNode/x86_64/os --serve-http=true --relative-url=rhelcomputenode/6/os/ --feed-ca-cert=/etc/rhsm/ca/redhat-uep.pem --feed-cert=/etc/pulp/rhel-hpcnode.pem --feed-key=/etc/pulp/rhel-hpcnode.pem
      pulp-admin rpm repo sync run --repo-id rhelhpcnode6 --bg
      #hpccomputenodeoptional
      pulp-admin rpm repo create --repo-id=rhelhpcnode6-optional --feed=https://cdn.redhat.com/content/dist/rhel/computenode/6/6ComputeNode/x86_64/optional/os --serve-http=true --relative-url=rhelcomputenode/6/optional/ --feed-ca-cert=/etc/rhsm/ca/redhat-uep.pem --feed-cert=/etc/pulp/rhel-hpcnode.pem --feed-key=/etc/pulp/rhel-hpcnode.pem
      pulp-admin rpm repo sync run --repo-id rhelhpcnode6-optional --bg
      #hpccomputenodesuplimentary
      pulp-admin rpm repo create --repo-id=rhelhpcnode6-supplementary --feed=https://cdn.redhat.com/content/dist/rhel/computenode/6/6ComputeNode/x86_64/supplementary/os --serve-http=true --relative-url=rhelcomputenode/6/supplementary/ --feed-ca-cert=/etc/rhsm/ca/redhat-uep.pem --feed-cert=/etc/pulp/rhel-hpcnode.pem --feed-key=/etc/pulp/rhel-hpcnode.pem
      pulp-admin rpm repo sync run --repo-id rhelhpcnode6-supplementary --bg
      cat $SYMPHONY_HOME/repo/yumconfigs/rhelhpcnode/6/yum-main.conf > $SYMPHONY_HOME/repo/yumconfigs/rhelhpcnode/6/yum.conf
      cat $SYMPHONY_HOME/repo/yumconfigs/rhelhpcnode/6/yum-repos.conf >> $SYMPHONY_HOME/repo/yumconfigs/rhelhpcnode/6/yum.conf
    else
      echo "Can't locate rhel HPC Compute Node entitlement certificate (/etc/pulp/rhel-hpcnode.pem), please refer to the symphony wiki" >&2
      exit 1
    fi
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
  el6symphony)
    pulp-admin rpm repo create --repo-id=symphony-el6 --feed=http://download.alces-software.com/repos/symphony/el6/ --serve-http=true --relative-url=symphony/el6
    pulp-admin rpm repo sync run --bg --repo-id=symphony-el6
    ;;
  el6alceshpc)
    pulp-admin rpm repo create --repo-id=alceshpc-base-el6 --feed=http://download.alces-software.com/repos/alces/latest/rhel/6.5/alces-hpc/base/ --serve-http=true --relative-url=alceshpc/el6/base
    pulp-admin rpm repo sync run --bg --repo-id=alceshpc-base-el6
    pulp-admin rpm repo create --repo-id=alceshpc-extras-el6 --feed=http://download.alces-software.com/repos/alces/latest/rhel/6.5/alces-hpc/extras/ --serve-http=true --relative-url=alceshpc/el6/extras
    pulp-admin rpm repo sync run --bg --repo-id=alceshpc-extras-el6
    pulp-admin rpm repo create --repo-id=alceshpc-extraslustreserver-el6 --feed=http://download.alces-software.com/repos/alces/latest/rhel/6.5/alces-hpc/extras-lustreserver/ --serve-http=true --relative-url=alceshpc/el6/extraslustreserver/
    pulp-admin rpm repo sync run --bg --repo-id=alceshpc-extraslustreserver-el6
    ;;
  *)
    echo "Unknown Group" >&2
    exit 1
    ;;
esac
