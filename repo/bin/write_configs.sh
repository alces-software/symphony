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

#SCRIPT TO GENERATE yum.conf FOR EACH DISRIBUTION TYPE DEPENDANT ON SOURCE REQUESTED IN yum-sources.conf FILE

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIGFILE=$BASEDIR/../etc/yum-sources.conf

#GET REPOSITORY CURRENT SET STATES TO BE CONFIGURED

echo -e "Reading Current Configuration...\n"

source $CONFIGFILE

#BUILD yum.conf FOR EACH DISTRIBUTION

function centos6 {
   STATE=$CENTOS6
   VERS=6
   CONFDIR="centos/$VERS"
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-main.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf >> $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum-repos.conf
   el6other
   el6symphony
   el6alceshpc
   el6rdoicehouse
   el6cephgiant
   el6lustre
   el6intellustre
}

function rhel6 {
   STATE=$RHEL6
   VERS=6
   CONFDIR="rhel/$VERS"
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-main.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf >> $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum-repos.conf
   el6other
   el6symphony
   el6alceshpc
   el6rdoicehouse
   el6lustre
   el6intellustre
}
function rhelcomputenode6 {
   STATE=$RHELCOMPUTENODE6
   VERS=6
   CONFDIR="rhelcomputenode/$VERS"
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-main.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf >> $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum-repos.conf
   el6other
   el6symphony
   el6alceshpc
   el6rdoicehouse
   el6lustre
   el6intellustre
}

function centos7 {
   STATE=$CENTOS7
   VERS=7
   CONFDIR="centos/$VERS"
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-main.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf >> $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum-repos.conf
   el7other
   el7symphony
   el7alceshpc
   el7rdojuno
   el7rdoicehouse
   el7rdokilo
   el7cephgiant
   el7cephhammer
   el7lustre
   el7intellustre
}

function sl6 {
   STATE=$SL6
   VERS=6
   CONFDIR="sl/$VERS"
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-main.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf >> $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum-repos.conf
   el6other
   el6symphony
   el6alceshpc
   el6rdoicehouse
   el6cephgiant
   el6lustre
   el6intellustre
}

function sl7 {
   STATE=$SL7
   VERS=7
   CONFDIR="sl/$VERS"
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-main.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf >> $BASEDIR/../yumconfigs/$CONFDIR/yum.conf
   cat $BASEDIR/../yumconfigs/$CONFDIR/yum-repos-$STATE.conf > $BASEDIR/../yumconfigs/$CONFDIR/yum-repos.conf
   el7other
   el7symphony
   el7alceshpc
   el7rdojuno
   el7rdoicehouse
   el7rdokilo
   el7cephgiant
   el7cephhammer
   el7lustre
   el7intellustre
}

#REPOSITORY GROUP

function el6other {
   STATE=$EL6OTHER
   epel $STATE $CONFDIR $VERS
   pulp $STATE $CONFDIR $VERS
   cobbler $STATE $CONFDIR $VERS
   puppet-base $STATE $CONFDIR $VERS
   puppet-deps $STATE $CONFDIR $VERS
}

function el6symphony {
   STATE=$EL6SYMPHONY
   symphony $STATE $CONFDIR $VERS
}

function el6alceshpc {
   STATE=$EL6ALCESHPC
   alceshpc $STATE $CONFDIR $VERS
}

function el7alceshpc {
   STATE=$EL7ALCESHPC
   alceshpc $STATE $CONFDIR $VERS
}

function el6lustre {
   STATE=$EL6LUSTRE
   lustre $STATE $CONFDIR $VERS
}

function el6intellustre {
   STATE=$EL6INTELLUSTRE
   intellustre $STATE $CONFDIR $VERS
}

function el7other {
   STATE=$EL7OTHER
   epel $STATE $CONFDIR $VERS
   pulp $STATE $CONFDIR $VERS
   cobbler $STATE $CONFDIR $VERS
   puppet-base $STATE $CONFDIR $VERS
   puppet-deps $STATE $CONFDIR $VERS
}

function el7symphony {
   STATE=$EL7SYMPHONY
   symphony $STATE $CONFDIR $VERS
}

function el7rdokilo {
   STATE=$EL7RDOKILO
   rdokilo $STATE $CONFDIR $VERS
}

function el7rdojuno {
   STATE=$EL7RDOJUNO
   rdojuno $STATE $CONFDIR $VERS
}

function el6rdoicehouse {
   STATE=$EL6RDOICEHOUSE
   rdoicehouse $STATE $CONFDIR $VERS
}

function el7rdoicehouse {
   STATE=$EL7RDOICEHOUSE
   rdoicehouse $STATE $CONFDIR $VERS
}

function el6cephgiant {
    STATE=$EL6CEPHGIANT
    cephgiant $STATE $CONFDIR $VERS
}

function el7cephgiant {
    STATE=$EL7CEPHGIANT
    cephgiant $STATE $CONFDIR $VERS
}

function el7cephhammer {
    STATE=$EL7CEPHHAMMER
    cephhammer $STATE $CONFDIR $VERS
}
function el7lustre {
    STATE=$EL7LUSTRE
    lustre $STATE $CONFDIR $VERS
}
function el7intellustre {
    STATE=$EL7INTELLUSTRE
    intellustre $STATE $CONFDIR $VERS
}


#PACKAGE REPOSITORIES

function epel {
   cat $BASEDIR/../yumconfigs/other/el$3/epel/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/other/el$3/epel/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function pulp {
   cat $BASEDIR/../yumconfigs/other/el$3/pulp/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/other/el$3/pulp/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function cobbler {
   cat $BASEDIR/../yumconfigs/other/el$3/cobbler/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/other/el$3/cobbler/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function puppet-base {
   cat $BASEDIR/../yumconfigs/other/el$3/puppet/base/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/other/el$3/puppet/base/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function puppet-deps {
   cat $BASEDIR/../yumconfigs/other/el$3/puppet/deps/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/other/el$3/puppet/deps/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function symphony {
   cat $BASEDIR/../yumconfigs/alces/symphony/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/alces/symphony/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function alceshpc {
   cat $BASEDIR/../yumconfigs/alces/alceshpc/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/alces/alceshpc/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function rdokilo {
   cat $BASEDIR/../yumconfigs/rdo/kilo/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/rdo/kilo/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function rdojuno {
   cat $BASEDIR/../yumconfigs/rdo/juno/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/rdo/juno/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function rdoicehouse {
   cat $BASEDIR/../yumconfigs/rdo/icehouse/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/rdo/icehouse/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function cephgiant {
   cat $BASEDIR/../yumconfigs/ceph/giant/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/ceph/giant/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function cephhammer {
   cat $BASEDIR/../yumconfigs/ceph/hammer/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/ceph/hammer/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function lustre {
   cat $BASEDIR/../yumconfigs/lustre/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/lustre/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

function intellustre {
   cat $BASEDIR/../yumconfigs/intellustre/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum.conf
   cat $BASEDIR/../yumconfigs/intellustre/el$3/yum-repos-$1.conf >> $BASEDIR/../yumconfigs/$2/yum-repos.conf
}

#FUNCTIONS TO RUN
echo -e "Building yum.conf Files for CentOS6...\n"
centos6
echo -e "Building yum.conf Files for RHEL6...\n"
rhel6
echo -e "Building yum.conf Files for RHEL6 HPC Compute Nodes...\n"
rhelcomputenode6
echo -e "Building yum.conf Files for CentOS7...\n"
centos7
echo -e "Building yum.conf Files for Scientific Linux 6...\n"
sl6
echo -e "Building yum.conf Files for Scientific Linux 7...\n"
sl7
