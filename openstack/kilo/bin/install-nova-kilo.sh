BUILDIP=10.78.
BUILDNETMASK=255.255.0.0
DNS=10.78.254.1

#SYMPHONY SYNC
scp -pr symphony-director:/var/lib/symphony /var/lib/.
cd /var/lib/symphony && git pull

#IPTABLES
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
-A INPUT -p udp -i br-build -m udp --dport 8472 -j ACCEPT
-A INPUT -p udp -i br-build -m multiport --dports 4789 -j ACCEPT
#SSH
-A INPUT -m state --state NEW -m tcp -p tcp -i br-build --dport 22 -j ACCEPT
#Nova VNC
-A INPUT -p tcp -m multiport --dports 5000:5999 -i br-build -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
systemctl stop iptables; systemctl start iptables

#NETWORK
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
ONBOOT=yes
DEVICETYPE=ovs
TYPE=OVSPort
OVS_BRIDGE=br-build
BOOTPROTO=none
HOTPLUG=no
EOF
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1
ONBOOT=yes
DEVICETYPE=ovs
TYPE=OVSPort
OVS_BRIDGE=br-prv
BOOTPROTO=none
HOTPLUG=no
EOF
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-br-prv
DEVICE=br-prv
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
IPADDR=$BUILDIP
NETMASK=$NETMASK
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
Configure the glance NFS mount
mkdir -p /var/lib/glance/images
echo "$STORAGE_IP:/var/lib/glance/images /var/lib/glance/images nfs defaults 0 0" >> /etc/fstab
mount /var/lib/glance/images

