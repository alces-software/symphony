#!/bin/bash

FSID=
ADMINKEY=
CINDERKEY=
GLANCEKEY=

VIRSHSECRET=

yum -y install ceph-common

cat << EOF > /etc/ceph/ceph.conf
[global]
fsid = $FSID
mon_initial_members = monitor1,monitor2,monitor3
mon_host = 10.110.0.61,10.110.0.62,10.110.0.63
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
filestore_xattr_use_omap = true
osd pool default size = 2
osd journal size = 1024
osd pool default min size = 1
osd pool default pg num = 256
osd pool default pgp num = 256
osd crush chooseleaf type = 1
#debug ms = 1
#debug rgw = 20
log file = /var/log/ceph/ceph.client.log
[client]
    rbd cache = true
    rbd cache size = 536870912
    rbd cache max dirty = 0
    #debug ms = 1
    #debug client = 20
    #debug rbd =
    #debug librbd = 1
    #debug objectcacher = 1
    rbd cache writethrough until flush = true
    admin socket = /var/run/ceph/guests/\$cluster-\$type.\$id.\$pid.\$cctid.asok
    log file = /var/log/qemu/qemu-guest-\$pid.log
    rbd concurrent management ops = 20
[client.admin]
	key = $ADMINKEY
        auid = 0
	caps mds = "allow"
	caps mon = "allow *"
	caps osd = "allow *"
[client.cinder]
	key = $CINDERKEY

[client.glance]
	key = $GLANCEKEY
EOF

chmod 644 /etc/ceph/ceph.conf

cat << EOF > /tmp/secret.xml
<secret ephemeral='no' private='no'>
  <uuid>$VIRSHSECRET</uuid>
  <usage type='ceph'>
    <name>client.cinder secret</name>
  </usage>
</secret>
EOF

service libvirtd start

virsh secret-define /tmp/secret.xml
virsh secret-set-value --secret $VIRSHSECRET --base64 $CINDERKEY

sed -i -e 's/^#images_rbd_pool=.*$/images_rbd_pool=cinder/g' /etc/nova/nova.conf
sed -i -e 's/^#rbd_user=.*$/rbd_user=cinder/g' /etc/nova/nova.conf
sed -i -e "s/^#rbd_secret_uuid=.*$/rbd_secret_uuid=$VIRSHSECRET/g" /etc/nova/nova.conf

