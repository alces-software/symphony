#!/bin/bash

#Load profile
PROFILE=`dirname $0 2>/dev/null`/../etc/novaprofiles/$1
if [ -f $PROFILE ]; then
 . $PROFILE
fi

#Network interface for prv
if [ -z "$PRV" ]; then
  PRV=vi0
fi
#Network interface for build
if [ -z "$BUILD" ]; then
  BUILD=vi1
fi
#Which interface to use as our DMZ bridge?
if [ -z "$DMZBR" ]; then
  DMZBR=em1.4
fi
#Which interface to use as our HPC/PRV bridge?
if [ -z "$PRVBR" ]; then
  PRVBR=em1.2
fi
#Which interface to user as our HPC/BUILD bridge?
if [ -z "$BUILDBR" ]; then 
  BUILDBR=em1
fi

#Sanitty checks
#Check glance is mounted
if ! ( mount -v | grep -q /var/lib/glance/images ); then
  echo "Please setup permanent glance image mount" >&2
  exit 1
fi 

function replace_or_add {
file=$1
search=$2
replace=$3
grep -q "$search" $file && sed "s/$search.*$/$replace/" -i $file || sed "$ a\\$replace" -i $file
}

#Packages
yum -y  install python-novaclient crudini openstack-utils openstack-neutron openvswitch openstack-neutron-openvswitch openstack-neutron-ml2 openstack-nova-compute sysfsutils

/opt/admin/alces/kiloconfigs/bin/install.sh nova/etc/nova/nova.conf /etc/nova/nova.conf
/opt/admin/alces/kiloconfigs/bin/install.sh nova/etc/neutron/neutron.conf /etc/neutron/neutron.conf
/opt/admin/alces/kiloconfigs/bin/install.sh nova/etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
/opt/admin/alces/kiloconfigs/bin/install.sh nova/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
ln -snf /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

#Firewall
systemctl disable firewalld.service
yum install -y iptables-services iptables-utils
systemctl stop firewalld.service
systemctl enable iptables
cat << EOF > /etc/sysconfig/iptables
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
#vxlan
-A INPUT -p udp -m udp --dport 8472 -i $PRV -j ACCEPT
-A INPUT -p udp -m multiport --dports 4789 -i $PRV -j ACCEPT
#SSH
-A INPUT -m state --state NEW -m tcp -p tcp -i $PRV --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp -i $BUILD --dport 22 -j ACCEPT
#Nova VNC
-A INPUT -p tcp -m multiport --dports 5000:5999 -i $PRV -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
#systemctl stop iptables; systemctl start iptables


#sys tweaks
cat <<EOF >> /etc/sysctl.conf
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
EOF
sysctl -p 

#OVS Bridges
cat > /etc/sysconfig/network-scripts/ifcfg-br-int << EOF
DEVICE=br-int
DEVICETYPE=ovs
TYPE=OVSBridge
ONBOOT=yes
BOOTPROTO=none
EOF
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-br-hpc
DEVICE=br-hpc
DEVICETYPE=ovs
TYPE=OVSBridge
ONBOOT=yes
BOOTPROTO=none
EOF
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-br-dmz
DEVICE=br-dmz
DEVICETYPE=ovs
TYPE=OVSBridge
ONBOOT=yes
BOOTPROTO=none
EOF
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-br-build
DEVICE=br-build
DEVICETYPE=ovs
TYPE=OVSBridge
ONBOOT=yes
BOOTPROTO=none
EOF
#OVS Ports
#Copy config from existing bridge interfaces to new virtual interfaces
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$PRV
DEVICE=$PRV
BOOTPROTO=none
DEVICETYPE=ovs
TYPE=OVSPort
OVS_BRIDGE=br-hpc
OVS_EXTRA="set Interface \$DEVICE type=internal"
ONBOOT=yes
ONPARENT=yes
EOF
grep -e '^IPADDR=' /etc/sysconfig/network-scripts/ifcfg-$PRVBR >> /etc/sysconfig/network-scripts/ifcfg-$PRV
grep -e '^NETMASK=' /etc/sysconfig/network-scripts/ifcfg-$PRVBR >> /etc/sysconfig/network-scripts/ifcfg-$PRV
grep -e '^NETWORK=' /etc/sysconfig/network-scripts/ifcfg-$PRVBR >> /etc/sysconfig/network-scripts/ifcfg-$PRV
grep -e '^GATEWAY=' /etc/sysconfig/network-scripts/ifcfg-$PRVBR >> /etc/sysconfig/network-scripts/ifcfg-$PRV
grep -e '^DNS' /etc/sysconfig/network-scripts/ifcfg-$PRVBR >> /etc/sysconfig/network-scripts/ifcfg-$PRV

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$BUILD
DEVICE=$BUILD
BOOTPROTO=none
DEVICETYPE=ovs
TYPE=OVSPort
OVS_BRIDGE=br-build
OVS_EXTRA="set Interface \$DEVICE type=internal"
ONBOOT=yes
ONPARENT=yes
EOF
grep -e '^IPADDR=' /etc/sysconfig/network-scripts/ifcfg-$BUILDBR >> /etc/sysconfig/network-scripts/ifcfg-$BUILD
grep -e '^NETMASK=' /etc/sysconfig/network-scripts/ifcfg-$BUILDBR >> /etc/sysconfig/network-scripts/ifcfg-$BUILD
grep -e '^NETWORK=' /etc/sysconfig/network-scripts/ifcfg-$BUILDBR >> /etc/sysconfig/network-scripts/ifcfg-$BUILD
grep -e '^GATEWAY=' /etc/sysconfig/network-scripts/ifcfg-$BUILDBR >> /etc/sysconfig/network-scripts/ifcfg-$BUILD
grep -e '^DNS' /etc/sysconfig/network-scripts/ifcfg-$BUILDBR >> /etc/sysconfig/network-scripts/ifcfg-$BUILD

file=/etc/sysconfig/network-scripts/ifcfg-$PRVBR
replace_or_add $file "^DEVICE=" "DEVICE=$PRVBR"
replace_or_add $file "^ONBOOT=" "ONBOOT=yes"
replace_or_add $file "^DEVICETYPE=" "DEVICETYPE=ovs"
replace_or_add $file "^TYPE=" "TYPE=OVSPort"
replace_or_add $file "^OVS_BRIDGE=" "OVS_BRIDGE=br-hpc"
replace_or_add $file "^BOOTPROTO=" "BOOTPROTO=none"
replace_or_add $file "^HOTPLUG=" "HOTPLUG=no"
sed -i $file -e 's/^IPADDR.*//g'
sed -i $file -e 's/^NETMASK.*//g'
sed -i $file -e 's/^NETWORK.*//g'
sed -i $file -e 's/^GATEWAY.*//g'
sed -i $file -e 's/^DNS.*//g'
sed -i $file -e '/^\s*$/d'
file=/etc/sysconfig/network-scripts/ifcfg-$DMZBR
replace_or_add $file "^DEVICE=" "DEVICE=$DMZBR"
replace_or_add $file "^ONBOOT=" "ONBOOT=yes"
replace_or_add $file "^DEVICETYPE=" "DEVICETYPE=ovs"
replace_or_add $file "^TYPE=" "TYPE=OVSPort"
replace_or_add $file "^OVS_BRIDGE=" "OVS_BRIDGE=br-dmz"
replace_or_add $file "^BOOTPROTO=" "BOOTPROTO=none"
replace_or_add $file "^HOTPLUG=" "HOTPLUG=no"
sed -i $file -e 's/^IPADDR.*//g'
sed -i $file -e 's/^NETMASK.*//g'
sed -i $file -e 's/^NETWORK.*//g'
sed -i $file -e 's/^GATEWAY.*//g'
sed -i $file -e 's/^DNS.*//g'
sed -i $file -e '/^\s*$/d'
file=/etc/sysconfig/network-scripts/ifcfg-$BUILDBR
replace_or_add $file "^DEVICE=" "DEVICE=$BUILDBR"
replace_or_add $file "^ONBOOT=" "ONBOOT=yes"
replace_or_add $file "^DEVICETYPE=" "DEVICETYPE=ovs"
replace_or_add $file "^TYPE=" "TYPE=OVSPort"
replace_or_add $file "^OVS_BRIDGE=" "OVS_BRIDGE=br-build"
replace_or_add $file "^BOOTPROTO=" "BOOTPROTO=none"
replace_or_add $file "^HOTPLUG=" "HOTPLUG=no"
sed -i $file -e 's/^IPADDR.*//g'
sed -i $file -e 's/^NETMASK.*//g'
sed -i $file -e 's/^NETWORK.*//g'
sed -i $file -e 's/^GATEWAY.*//g'
sed -i $file -e 's/^DNS.*//g'
sed -i $file -e '/^\s*$/d'
ifup br-int
ifup br-hpc
ifup br-dmz
ifup br-build
ifup $PRV
ifup $BUILD
ifup $PRVBR
ifup $DMZBR
ifup $BUILDBR

#service openstack-nova-compute start
#service libvirtd start
chkconfig openstack-nova-compute on
chkconfig libvirtd on
#service openvswitch start
chkconfig openvswitch on
#service neutron-openvswitch-agent start
chkconfig neutron-openvswitch-agent on
