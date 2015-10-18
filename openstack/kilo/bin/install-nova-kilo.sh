#DNS
DNS=10.78.254.1
#My interface on the build network
BUILDINT=`test -z "$1" && echo "eth0" || echo "$1"`
#My interface on the private network
PRVINT=`test -z "$2" && echo "eth1" || echo "$2"`

#Build IP of the machine being configured
BUILDIP=`facter ipaddress_$BUILDINT`
#Netmask of the build interface
BUILDNETMASK=`facter netmask_$BUILDINT`

#Private IP of the machine being configured
PRVIP=`facter ipaddress_$PRVINT`
#Netmask of the build interface
PRVNETMASK=`facter netmask_$PRVINT`

#IPTABLES
systemctl disable firewalld.service
yum install -y iptables-services iptables-utils syslinux
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
-A INPUT -p udp -i br-build -m udp --dport 8472 -j ACCEPT
-A INPUT -p udp -i br-build -m multiport --dports 4789 -j ACCEPT
#SSH
-A INPUT -m state --state NEW -m tcp -p tcp -i br-build --dport 22 -j ACCEPT
#Nova VNC
-A INPUT -p tcp -m multiport --dports 5000:5999 -i br-build -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
systemctl stop iptables; systemctl start iptables

#NETWORK
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$BUILDINT
DEVICE=$BUILDINT
ONBOOT=yes
DEVICETYPE=ovs
TYPE=OVSPort
OVS_BRIDGE=br-build
BOOTPROTO=none
HOTPLUG=no
EOF
if ( echo $BUILDINT | grep -qe "^.*\.[0-9]*" ); then
  echo VLAN=yes >> /etc/sysconfig/network-scripts/ifcfg-$BUILDINT
fi
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$PRVINT
DEVICE=$PRVINT
ONBOOT=yes
DEVICETYPE=ovs
TYPE=OVSPort
OVS_BRIDGE=br-prv
BOOTPROTO=none
HOTPLUG=no
EOF
if ( echo $PRVINT | grep -qe "^.*\.[0-9]*" ); then
  echo VLAN=yes >> /etc/sysconfig/network-scripts/ifcfg-$PRVINT
fi
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-br-prv
DEVICE=br-prv
DEVICETYPE=ovs
TYPE=OVSBridge
ONBOOT=yes
BOOTPROTO=none
IPADDR=$PRVIP
NETMASK=$PRVNETMASK
DNS1=$DNS
EOF
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-br-build
DEVICE=br-build
DEVICETYPE=ovs
TYPE=OVSBridge
ONBOOT=yes
BOOTPROTO=none
IPADDR=$BUILDIP
NETMASK=$BUILDNETMASK
DNS1=$DNS
EOF
cat > /etc/sysconfig/network-scripts/ifcfg-br-int << EOF
DEVICE=br-int
DEVICETYPE=ovs
TYPE=OVSBridge
ONBOOT=yes
BOOTPROTO=none
EOF

#SYS
cat <<EOF >> /etc/sysctl.conf
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
EOF
sysctl -p

#OPENSTACK
yum -y  install python-novaclient crudini openstack-utils openstack-neutron openvswitch openstack-neutron-openvswitch openstack-neutron-ml2 openstack-nova-compute sysfsutils
/var/lib/symphony/openstack/kilo/bin/install.sh nova/etc/nova/nova.conf /etc/nova/nova.conf
/var/lib/symphony/openstack/kilo/bin/install.sh nova/etc/neutron/neutron.conf /etc/neutron/neutron.conf
/var/lib/symphony/openstack/kilo/bin/install.sh nova/etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
/var/lib/symphony/openstack/kilo/bin/install.sh nova/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini
ln -snf /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
service openstack-nova-compute start
service libvirtd start
chkconfig openstack-nova-compute on
chkconfig libvirtd on
service openvswitch start
chkconfig openvswitch on
service neutron-openvswitch-agent start
chkconfig neutron-openvswitch-agent on

#NFS
. /var/lib/symphony/openstack/kilo/bin/vars
#Configure the glance NFS mount
mkdir -p /var/lib/glance/images
echo "$STORAGE_IP:/var/lib/glance/images /var/lib/glance/images nfs defaults 0 0" >> /etc/fstab
mount /var/lib/glance/images

