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

AVAILABLE_GROUPS="centos6 el6other centos7 el7other el6symphony el7symphony rhel6 rhelhpcnode6 el6alceshpc el7alceshpc sl6 sl7 el7rdokilo el7rdojuno el6rdoicehouse el7rdoicehouse el6ceph-giant el7ceph-giant el7ceph-hammer el6lustre el7lustre intellustre"

GROUP=$1

if [ -z $GROUP ]; then
  echo "Please specify group, Available Groups: [$AVAILABLE_GROUPS]" >&2
  exit 1
fi

PROXY_HOST=
PROXY_USER=
PROXY_PORT=3128
PROXY_PASS=

if ! [ -z $PROXY_HOST ] && ! [ -z $PROXY_PORT ]; then
  proxy="--proxy-host $PROXY_HOST --proxy-port $PROXY_PORT"
fi
if ! [ -z $PROXY_USER ] && ! [ -z $PROXY_PASS ]; then
  proxy="$proxy --proxy-user $PROXY_USER --proxy-pass $PROXY_PASS"
fi

case $GROUP in
  centos6) 
    #base
    pulp-admin rpm repo create --repo-id=centos6 --feed=http://www.mirrorservice.org/sites/mirror.centos.org/6/os/x86_64/ --serve-http=true --relative-url=centos/6/os/ $proxy
    pulp-admin rpm repo sync run --repo-id centos6 --bg
    #updates
    pulp-admin rpm repo create --repo-id=centos6-updates --feed=http://www.mirrorservice.org/sites/mirror.centos.org/6/updates/x86_64/ --serve-http=true --relative-url=centos/6/updates $proxy
    pulp-admin rpm repo sync run --repo-id centos6-updates --bg
    ;;
  sl6)
    #base
    pulp-admin rpm repo create --repo-id=sl6 --feed=http://anorien.csc.warwick.ac.uk/mirrors/scientific/6x/x86_64/os/ --serve-http=true --relative-url=sl/6/os/ $proxy
    pulp-admin rpm repo sync run --repo-id sl6 --bg
    #fastbugs
    pulp-admin rpm repo create --repo-id=sl6-fastbugs --feed=http://anorien.csc.warwick.ac.uk/mirrors/scientific/6x/x86_64/updates/fastbugs/ --serve-http=true --relative-url=sl/6/fastbugs $proxy
    pulp-admin rpm repo sync run --repo-id sl6-fastbugs --bg
    #security
    pulp-admin rpm repo create --repo-id=sl6-security --feed=http://anorien.csc.warwick.ac.uk/mirrors/scientific/6x/x86_64/updates/security/ --serve-http=true --relative-url=sl/6/security $proxy
    pulp-admin rpm repo sync run --repo-id sl6-security --bg
    ;;
  sl7)
    #base
    pulp-admin rpm repo create --repo-id=sl7 --feed=http://anorien.csc.warwick.ac.uk/mirrors/scientific/7x/x86_64/os/ --serve-http=true --relative-url=sl/7/os/ $proxy
    pulp-admin rpm repo sync run --repo-id sl7 --bg
    #fastbugs
    pulp-admin rpm repo create --repo-id=sl7-fastbugs --feed=http://anorien.csc.warwick.ac.uk/mirrors/scientific/7x/x86_64/updates/fastbugs/ --serve-http=true --relative-url=sl/7/fastbugs $proxy
    pulp-admin rpm repo sync run --repo-id sl7-fastbugs --bg
    #security
    pulp-admin rpm repo create --repo-id=sl7-security --feed=http://anorien.csc.warwick.ac.uk/mirrors/scientific/7x/x86_64/updates/security/ --serve-http=true --relative-url=sl/7/security $proxy
    pulp-admin rpm repo sync run --repo-id sl7-security --bg
    #extras
    pulp-admin rpm repo create --repo-id=sl7-extras --feed=http://anorien.csc.warwick.ac.uk/mirrors/scientific/7x/external_products/extras/x86_64/ --serve-http=true --relative-url=sl/7/extras $proxy
    pulp-admin rpm repo sync run --repo-id sl7-extras --bg
    ;;
  rhel6)
    #Create a boot path from supplied iso
    if ! [ -f $SYMPHONY_HOME/repo/iso/rhel6.iso ]; then
      echo "Boot ISO not found, please download the boot ISO and place in $SYMPHONY_HOME/repo/iso/rhel6.iso" >&2
      exit 1
    else
      mkdir -p /var/www/html/static/rhel/6/boot/
      mkdir /tmp/symphonyiso.$$
      mount -o loop $SYMPHONY_HOME/repo/iso/rhel6.iso /tmp/symphonyiso.$$
      rsync -pa /tmp/symphonyiso.$$/* /var/www/html/static/rhel/6/boot/.
      umount /tmp/symphonyiso.$$
      rmdir /tmp/symphonyiso.$$
      chown -R apache:apache /var/www/html/static
    fi
    if [ -f /etc/pulp/rhel.pem ]; then 
      #base
      pulp-admin rpm repo create --repo-id=rhel6 --feed=https://cdn.redhat.com/content/dist/rhel/server/6/6Server/x86_64/os --serve-http=true --relative-url=rhel/6/os/ --feed-ca-cert=/etc/rhsm/ca/redhat-uep.pem --feed-cert=/etc/pulp/rhel.pem --feed-key=/etc/pulp/rhel.pem $proxy
      pulp-admin rpm repo sync run --repo-id rhel6 --bg
      #optional
      pulp-admin rpm repo create --repo-id=rhel6-optional --feed=https://cdn.redhat.com/content/dist/rhel/server/6/6Server/x86_64/optional/os --serve-http=true --relative-url=rhel/6/optional/ --feed-ca-cert=/etc/rhsm/ca/redhat-uep.pem --feed-cert=/etc/pulp/rhel.pem --feed-key=/etc/pulp/rhel.pem $proxy
      pulp-admin rpm repo sync run --repo-id rhel6-optional --bg
    else
      echo "Can't locate rhel server entitlement certificate (/etc/pulp/rhel.pem), please refer to symphony wiki" >&2
      exit 1
    fi
    ;;
  rhelhpcnode6)
    #Create a boot path
    if ! [ -f $SYMPHONY_HOME/repo/iso/rhelhpcnode6.iso ]; then
      echo "Boot ISO not found, please download the boot ISO and place in $SYMPHONY_HOME/repo/iso/rhelhpcnode6.iso" >&2
      exit 1
    else
      mkdir -p /var/www/html/static/rhelcomputenode/6/boot/
      mkdir /tmp/symphonyiso.$$
      mount -o loop $SYMPHONY_HOME/repo/iso/rhelhpcnode6.iso /tmp/symphonyiso.$$
      rsync -pa /tmp/symphonyiso.$$/* /var/www/html/static/rhelcomputenode/6/boot/.
      umount /tmp/symphonyiso.$$
      rmdir /tmp/symphonyiso.$$ 
      chown -R apache:apache /var/www/html/static
    fi
    if [ -f /etc/pulp/rhel-hpcnode.pem ]; then
      #hpccomputenodebase
      pulp-admin rpm repo create --repo-id=rhelhpcnode6 --feed=https://cdn.redhat.com/content/dist/rhel/computenode/6/6ComputeNode/x86_64/os --serve-http=true --relative-url=rhelcomputenode/6/os/ --feed-ca-cert=/etc/rhsm/ca/redhat-uep.pem --feed-cert=/etc/pulp/rhel-hpcnode.pem --feed-key=/etc/pulp/rhel-hpcnode.pem $proxy
      pulp-admin rpm repo sync run --repo-id rhelhpcnode6 --bg
      #hpccomputenodeoptional
      pulp-admin rpm repo create --repo-id=rhelhpcnode6-optional --feed=https://cdn.redhat.com/content/dist/rhel/computenode/6/6ComputeNode/x86_64/optional/os --serve-http=true --relative-url=rhelcomputenode/6/optional/ --feed-ca-cert=/etc/rhsm/ca/redhat-uep.pem --feed-cert=/etc/pulp/rhel-hpcnode.pem --feed-key=/etc/pulp/rhel-hpcnode.pem $proxy
      pulp-admin rpm repo sync run --repo-id rhelhpcnode6-optional --bg
      #hpccomputenodesuplimentary
      pulp-admin rpm repo create --repo-id=rhelhpcnode6-supplementary --feed=https://cdn.redhat.com/content/dist/rhel/computenode/6/6ComputeNode/x86_64/supplementary/os --serve-http=true --relative-url=rhelcomputenode/6/supplementary/ --feed-ca-cert=/etc/rhsm/ca/redhat-uep.pem --feed-cert=/etc/pulp/rhel-hpcnode.pem --feed-key=/etc/pulp/rhel-hpcnode.pem $proxy
      pulp-admin rpm repo sync run --repo-id rhelhpcnode6-supplementary --bg
    else
      echo "Can't locate rhel HPC Compute Node entitlement certificate (/etc/pulp/rhel-hpcnode.pem), please refer to the symphony wiki" >&2
      exit 1
    fi
    ;;
  el6other)
    #epel
    pulp-admin rpm repo create --repo-id=epel6 --feed=http://anorien.csc.warwick.ac.uk/mirrors/epel/6/x86_64/ --serve-http=true --relative-url=epel6 --skip erratum $proxy
    pulp-admin rpm repo sync run --bg --repo-id=epel6
    #cobbler
    pulp-admin rpm repo create --repo-id=cobbler-el6 --feed=http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-6/ --serve-http=true --relative-url=cobbler/el6 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=cobbler-el6
    #pulp
    pulp-admin rpm repo create --repo-id=pulp-el6 --feed=https://repos.fedorapeople.org/repos/pulp/pulp/stable/2/6Server/x86_64/ --serve-http=true --relative-url=pulp/el6 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=pulp-el6
    #puppet-deps
    pulp-admin rpm repo create --repo-id=puppet-deps-el6 --feed=https://yum.puppetlabs.com/el/6/dependencies/x86_64/ --serve-http=true --relative-url=puppet/deps/el6 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=puppet-deps-el6
    #puppet-base
    pulp-admin rpm repo create --repo-id=puppet-base-el6 --feed=https://yum.puppetlabs.com/el/6/products/x86_64 --serve-http=true --relative-url=puppet/base/el6 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=puppet-base-el6
    ;;
  centos7)
    #base
    pulp-admin rpm repo create --repo-id=centos7 --feed=http://www.mirrorservice.org/sites/mirror.centos.org/7/os/x86_64/ --serve-http=true --relative-url=centos/7/os/ $proxy
    pulp-admin rpm repo sync run --repo-id centos7 --bg
    #updates
    pulp-admin rpm repo create --repo-id=centos7-updates --feed=http://www.mirrorservice.org/sites/mirror.centos.org/7/updates/x86_64/ --serve-http=true --relative-url=centos/7/updates $proxy
    pulp-admin rpm repo sync run --repo-id centos7-updates --bg
    #extras
    pulp-admin rpm repo create --repo-id=centos7-extras --feed=http://www.mirrorservice.org/sites/mirror.centos.org/7/extras/x86_64/ --serve-http=true --relative-url=centos/7/extras $proxy
    pulp-admin rpm repo sync run --repo-id centos7-extras --bg
    ;;
  el7other)
    #epel
    pulp-admin rpm repo create --repo-id=epel7 --feed=http://anorien.csc.warwick.ac.uk/mirrors/epel/7/x86_64/ --serve-http=true --relative-url=epel7 --skip erratum $proxy
    pulp-admin rpm repo sync run --bg --repo-id=epel7
    #cobbler
    pulp-admin rpm repo create --repo-id=cobbler-el7 --feed=http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-7/ --serve-http=true --relative-url=cobbler/el7 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=cobbler-el7
    #pulp
    pulp-admin rpm repo create --repo-id=pulp-el7 --feed=https://repos.fedorapeople.org/repos/pulp/pulp/stable/2/7Server/x86_64/ --serve-http=true --relative-url=pulp/el7 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=pulp-el7
    #puppet-deps
    pulp-admin rpm repo create --repo-id=puppet-deps-el7 --feed=https://yum.puppetlabs.com/el/7/dependencies/x86_64/ --serve-http=true --relative-url=puppet/deps/el7 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=puppet-deps-el7
    #puppet-base
    pulp-admin rpm repo create --repo-id=puppet-base-el7 --feed=https://yum.puppetlabs.com/el/7/products/x86_64 --serve-http=true --relative-url=puppet/base/el7 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=puppet-base-el7
    ;;
  el7symphony)
    pulp-admin rpm repo create --repo-id=symphony-el7 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/symphony/el7/ --serve-http=true --relative-url=symphony/el7 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=symphony-el7
    ;;
  el6symphony)
    pulp-admin rpm repo create --repo-id=symphony-el6 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/symphony/el6/ --serve-http=true --relative-url=symphony/el6 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=symphony-el6
    ;;
  el6alceshpc)
    pulp-admin rpm repo create --repo-id=alceshpc-base-el6 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/alces-hpc/base --serve-http=true --relative-url=alceshpc/el6/base $proxy
    pulp-admin rpm repo sync run --bg --repo-id=alceshpc-base-el6
    pulp-admin rpm repo create --repo-id=alceshpc-extras-el6 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/alces-hpc/extras/ --serve-http=true --relative-url=alceshpc/el6/extras $proxy
    pulp-admin rpm repo sync run --bg --repo-id=alceshpc-extras-el6
    pulp-admin rpm repo create --repo-id=alceshpc-extraslustreserver-el6 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/alces-hpc/extras-lustreserver/ --serve-http=true --relative-url=alceshpc/el6/extraslustreserver/ $proxy
    pulp-admin rpm repo sync run --bg --repo-id=alceshpc-extraslustreserver-el6
    ;;
  el7alceshpc)
    pulp-admin rpm repo create --repo-id=alceshpc-base-el7 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/alceshpc/base/el7 --serve-http=true --relative-url=alceshpc/el7/base $proxy
    pulp-admin rpm repo sync run --bg --repo-id=alceshpc-base-el7
    pulp-admin rpm repo create --repo-id=alceshpc-extras-el7 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/alceshpc/extras/el7 --serve-http=true --relative-url=alceshpc/el7/extras $proxy
    pulp-admin rpm repo sync run --bg --repo-id=alceshpc-extras-el7
    ;;
  el7rdokilo)
    pulp-admin rpm repo create --repo-id=el7rdokilo --feed=https://repos.fedorapeople.org/repos/openstack/openstack-kilo/el7/ --serve-http=true --relative-url=rdo/kilo/el7 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el7rdokilo
    ;; 
  el7rdojuno)
    pulp-admin rpm repo create --repo-id=el7rdojuno --feed=https://repos.fedorapeople.org/repos/openstack/openstack-juno/epel-7/ --serve-http=true --relative-url=rdo/juno/el7 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el7rdojuno
    ;;
  el7rdoicehouse)
    pulp-admin rpm repo create --repo-id=el7rdoicehouse --feed=https://repos.fedorapeople.org/repos/openstack/openstack-icehouse/epel-7/ --serve-http=true --relative-url=rdo/icehouse/el7 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el7rdoicehouse
    ;;
  el6rdoicehouse)
    pulp-admin rpm repo create --repo-id=el6rdoicehouse --feed=https://repos.fedorapeople.org/repos/openstack/openstack-icehouse/epel-6/ --serve-http=true --relative-url=rdo/icehouse/el6 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el6rdoicehouse
    ;;
  el7ceph-giant)
    pulp-admin rpm repo create --repo-id=el7ceph-giant-x86_64 --feed=http://ceph.com/rpm-giant/el7/x86_64 --serve-http=true --relative-url=ceph/giant/el7/x86_64 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el7ceph-giant-x86_64
    pulp-admin rpm repo create --repo-id=el7ceph-giant-noarch --feed=http://ceph.com/rpm-giant/el7/noarch --serve-http=true --relative-url=ceph/giant/el7/noarch  $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el7ceph-giant-noarch
    pulp-admin rpm repo create --repo-id=el7ceph-giant-apache --feed=http://gitbuilder.ceph.com/deprecated/apache2-rpm-centos7-x86_64-basic/ref/master --serve-http=true --relative-url=ceph/giant/el7/apache $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el7ceph-giant-apache
    pulp-admin rpm repo create --repo-id=el7ceph-giant-fastcgi --feed=http://gitbuilder.ceph.com/mod_fastcgi-rpm-centos7-x86_64-basic/ref/master --serve-http=true --relative-url=ceph/giant/el7/fastcgi $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el7ceph-giant-fastcgi
    ;;
  el7ceph-hammer)
    pulp-admin rpm repo create --repo-id=el7ceph-hammer-x86_64 --feed=http://ceph.com/rpm-hammer/el7/x86_64 --serve-http=true --relative-url=ceph/hammer/el7/x86_64 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el7ceph-hammer-x86_64
    pulp-admin rpm repo create --repo-id=el7ceph-hammer-noarch --feed=http://ceph.com/rpm-hammer/el7/noarch --serve-http=true --relative-url=ceph/hammer/el7/noarch  $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el7ceph-hammer-noarch
    pulp-admin rpm repo create --repo-id=el7ceph-hammer-apache --feed=http://gitbuilder.ceph.com/deprecated/apache2-rpm-centos7-x86_64-basic/ref/master --serve-http=true --relative-url=ceph/hammer/el7/apache $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el7ceph-hammer-apache
    pulp-admin rpm repo create --repo-id=el7ceph-hammer-fastcgi --feed=http://gitbuilder.ceph.com/mod_fastcgi-rpm-centos7-x86_64-basic/ref/master --serve-http=true --relative-url=ceph/hammer/el7/fastcgi $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el7ceph-hammer-fastcgi
    ;; 
  el6ceph-giant)
    pulp-admin rpm repo create --repo-id=el6ceph-giant-x86_64 --feed=http://ceph.com/rpm-giant/el6/x86_64 --serve-http=true --relative-url=ceph/giant/el6/x86_64  $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el6ceph-giant-x86_64
    pulp-admin rpm repo create --repo-id=el6ceph-giant-noarch --feed=http://ceph.com/rpm-giant/el6/noarch --serve-http=true --relative-url=ceph/giant/el6/noarch $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el6ceph-giant-noarch
    pulp-admin rpm repo create --repo-id=el6ceph-giant-extras-x86_64 --feed=http://ceph.com/packages/ceph-extras/rpm/centos6/x86_64 --serve-http=true --relative-url=ceph/giant/el6/extras/x86_64 $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el6ceph-giant-extras-x86_64
    pulp-admin rpm repo create --repo-id=el6ceph-giant-extras-noarch --feed=http://ceph.com/packages/ceph-extras/rpm/centos6/noarch --serve-http=true --relative-url=ceph/giant/el6/extras/noarch $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el6ceph-giant-extras-noarch
    pulp-admin rpm repo create --repo-id=el6ceph-giant-apache --feed=http://gitbuilder.ceph.com/deprecated/apache2-rpm-centos6-x86_64-basic/ref/master --serve-http=true --relative-url=ceph/giant/el6/apache $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el6ceph-giant-apache
    pulp-admin rpm repo create --repo-id=el6ceph-giant-fastcgi --feed=http://gitbuilder.ceph.com/mod_fastcgi-rpm-centos6-x86_64-basic/ref/master --serve-http=true --relative-url=ceph/giant/el6/fastcgi $proxy
    pulp-admin rpm repo sync run --bg --repo-id=el6ceph-giant-fastcgi
    ;;
   el6lustre)
     pulp-admin rpm repo create --repo-id=lustre-server-el6 --feed=https://downloads.hpdd.intel.com/public/lustre/latest-maintenance-release/el6/server/ --serve-http=true --relative-url=lustre/el6/server/
     pulp-admin rpm repo sync run --bg --repo-id=lustre-server-el6
     pulp-admin rpm repo create --repo-id=lustre-client-el6 --feed=https://downloads.hpdd.intel.com/public/lustre/latest-maintenance-release/el6/client/ --serve-http=true --relative-url=lustre/el6/client/
     pulp-admin rpm repo sync run --bg --repo-id=lustre-client-el6
     pulp-admin rpm repo create --repo-id=lustre-e2fsprogs-el6 --feed=https://downloads.hpdd.intel.com/public/e2fsprogs/latest/el6/ --serve-http=true --relative-url=lustre/el6/e2fsprogs/
     pulp-admin rpm repo sync run --bg --repo-id=lustre-e2fsprogs-el6
     pulp-admin rpm repo create --repo-id=lustre-extra-el6 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/lustre/el6/extra/ --serve-http=true --relative-url=lustre/el6/extra/
     pulp-admin rpm repo sync run --bg --repo-id=lustre-extra-el6
     ;;
   el7lustre)
     pulp-admin rpm repo create --repo-id=lustre-client-el7 --feed=https://downloads.hpdd.intel.com/public/lustre/latest-feature-release/el7/client/ --serve-http=true --relative-url=lustre/el7/client/
     pulp-admin rpm repo sync run --bg --repo-id=lustre-client-el7
     pulp-admin rpm repo create --repo-id=lustre-extra-el7 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/lustre/el7/extra/ --serve-http=true --relative-url=lustre/el7/extra/
     pulp-admin rpm repo sync run --bg --repo-id=lustre-extra-el7
     ;;
   intellustre)
     pulp-admin rpm repo create --repo-id=intellustre-server-el6 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/lustre/intel/2.3.0.0/server/el6/ --serve-http=true --relative-url=intellustre/el6/server/
     pulp-admin rpm repo sync run --bg --repo-id=intellustre-server-el6
     pulp-admin rpm repo create --repo-id=intellustre-client-el6 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/lustre/intel/2.3.0.0/client/el6/ --serve-http=true --relative-url=intellustre/el6/client/
     pulp-admin rpm repo sync run --bg --repo-id=intellustre-client-el6
     pulp-admin rpm repo create --repo-id=intellustre-e2fsprogs-el6 --feed=https://downloads.hpdd.intel.com/public/e2fsprogs/latest/el6/ --serve-http=true --relative-url=intellustre/el6/e2fsprogs/
     pulp-admin rpm repo sync run --bg --repo-id=intellustre-e2fsprogs-el6
     pulp-admin rpm repo create --repo-id=intellustre-extra-el6 --feed=https://s3-eu-west-1.amazonaws.com/repos.alces-software.com/lustre/intel/2.3.0.0/extra/el6/ --serve-http=true --relative-url=intellustre/el6/extra/
     pulp-admin rpm repo sync run --bg --repo-id=intellustre-extra-el6
     ;;
   *)
    echo "Unknown Group" >&2
    exit 1
    ;;
esac
