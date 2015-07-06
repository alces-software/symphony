#!/bin/bash
set -x

if [ -f /etc/profile.d/modules.sh ]; then
  . /etc/profile.d/modules.sh
elif [ -f /etc/profile.d/alces-clusterware.sh ]; then
  . /etc/profile.d/alces-clusterware.sh
else
  echo "Unable to locate environment modules initialization script."
  exit 1
fi

# XXX - this path should not be hard-coded
STACK_ROOT=/opt/service

arch=$($SGE_ROOT/util/arch)
$SGE_ROOT/utilbin/$arch/spoolinit classic libspoolc "/opt/service/gridscheduler/2011.11p1_155/etc/conf;/var/spool/gridscheduler/qmaster" init

chown geadmin:geadmin -R /var/spool/gridscheduler
chown geadmin:geadmin -R /opt/service/gridscheduler/2011.11p1_155/etc

#Only continue if qmaster is started
if !(/etc/init.d/qmaster.alces-gridscheduler status); then
  echo "Skipping Qconf - qmaster is not running"
  exit 1
fi

module purge
module use $STACK_ROOT/etc/modules
module load services/gridscheduler
TEMPLATES_ROOT=$STACK_ROOT/gridscheduler/2011.11p1_155/etc/templates

qconf -am geadmin
qconf -as `hostname`

for a in $TEMPLATES_ROOT/host/*; do
    qconf -Ae $a || qconf -Me $a
done

for a in $TEMPLATES_ROOT/hostgroup/*; do
    qconf -Ahgrp $a || qconf -Mhgrp $a
done

for a in $TEMPLATES_ROOT/pe/*; do
    qconf -Ap $a || qconf -Mp $a
done

# delete the default queue
qconf -dq all.q
for a in $TEMPLATES_ROOT/queue/*; do
    qconf -Aq $a || qconf -Mq $a
done

#make serial and parallel queues subordinate each other                                                       
qconf -mattr queue subordinate_list 'serial.q=1 smp.q=1' parallel.q
qconf -mattr queue subordinate_list 'parallel.q=1 smp.q=1' serial.q
qconf -mattr queue subordinate_list 'serial.q=1 parallel.q=1' smp.q

if [ -f /etc/SuSE-release ]; then
  /etc/init.d/qmaster.alces-gridscheduler restart
else
  service qmaster.alces-gridscheduler stop
  service qmaster.alces-gridscheduler start
fi
