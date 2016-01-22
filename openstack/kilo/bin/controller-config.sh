#!/bin/bash

echo "Have you copied <clientname>.crt.pem to /etc/certs/nova_crt.pem"
echo "Have you copeid <clientname>.key.pem to /etc/certs/nova_key.pem"
echo "Have you updates /var/lib/symphony/openstack/kilo/bin/vars with CLUSTER ADMINPASS" 
echo "Press any key to continue.."; read

#NEWTOKEN=`openssl rand -hex 10`
#sed -i /var/lib/symphony/openstack/kilo/bin/vars -e "s/^KEYSTONEADMINTOKEN=.*$/KEYSTONEADMINTOKEN=$NEWTOKEN/g"

. /var/lib/symphony/openstack/kilo/bin/vars

#Change service passwords
rabbitmqctl change_password guest "$ADMINPASS"
rabbitmqctl change_password openstackservices "$ADMINPASS"
mysqladmin -u root -p"PassW0rd" password $ADMINPASS
echo "GRANT ALL ON *.* TO 'openstack'@'%' IDENTIFIED BY '$ADMINPASS'; GRANT ALL ON *.* TO 'openstack'@'localhost' IDENTIFIED BY '$ADMINPASS'; FLUSH PRIVILEGES;" | mysql -u root -p$ADMINPASS

#Fixup Keystone
sh /var/lib/symphony/openstack/kilo/bin/install.sh controller/etc/keystone/keystone.conf /etc/keystone/keystone.conf

#Fixup FQDN
sh /var/lib/symphony/openstack/kilo/bin/install.sh controller/etc/nginx/nginx.conf /etc/nginx/nginx.conf
sh /var/lib/symphony/openstack/kilo/bin/install.sh controller/etc/nova/nova.conf /etc/nova/nova.conf
sh /var/lib/symphony/openstack/kilo/bin/install.sh controller/etc/httpd/conf.d/redirect-to-https.conf /etc/httpd/conf.d/redirect.conf
sh /var/lib/symphony/openstack/kilo/bin/install.sh controller/etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf
sh /var/lib/symphony/openstack/kilo/bin/install.sh controller/etc/heat/heat.conf /etc/heat/heat.conf

#Fixup Certs
cp /etc/certs/nova_crt.pem /etc/certs/apache_crt.pem
cp /etc/certs/nova_crt.pem /etc/certs/nginx_crt.pem
cat /etc/certs/ca_crt >> /etc/certs/apache_crt.pem
cat /etc/certs/ca_crt >> /etc/certs/nginx_crt.pem
cp -pav /etc/certs/nova_key.pem /etc/certs/apache_key.pem
cp -pav /etc/certs/nova_key.pem /etc/certs/nginx_key.pem
chown nova:nova /etc/certs/nova*
chown nginx:nginx /etc/certs/nginx*
chmod 600 /etc/certs/*

#Fixup auth file
cat << EOF > ~/keystonerc_stackadmin
export OS_USERNAME=stackadmin
export OS_TENANT_NAME=admin
export OS_PASSWORD="$ADMINPASS"
export OS_AUTH_URL=https://$FQDN:8080/keystone/v2.0/
export PS1="[\$OS_USERNAME] \$PS1"
EOF

service httpd restart

export OS_TOKEN=$KEYSTONEADMINTOKEN
export OS_URL="http://`hostname -f`:35357/v2.0"

openstack endpoint list | grep 'None' | cut -d '|' -f 2 | while read n; do openstack endpoint delete $n; done

openstack endpoint create \
        --publicurl "https://$FQDN:8080/keystone/v2.0" \
        --adminurl "http://$CONTROLLER_IP:35357/v2.0" \
        --internalurl "http://$CONTROLLER_IP:5000/v2.0" \
        keystone
openstack endpoint create \
        --publicurl "https://$FQDN:8080/glance/" \
        --adminurl "http://$STORAGE_IP:9292" \
        --internalurl "http://$STORAGE_IP:9292" glance
openstack endpoint create \
        cinder \
        --publicurl "https://$FQDN:8080/cinder/v1/%(tenant_id)s" \
        --adminurl "http://$STORAGE_IP:8776/v1/%(tenant_id)s" \
        --internalurl "http://$STORAGE_IP:8776/v1/%(tenant_id)s"
openstack endpoint create \
        cinderv2 \
        --publicurl "https://$FQDN:8080/cinder/v2/%(tenant_id)s" \
        --adminurl "http://$STORAGE_IP:8776/v2/%(tenant_id)s" \
        --internalurl "http://$STORAGE_IP:8776/v2/%(tenant_id)s"
openstack endpoint create \
  compute \
  --publicurl https://$FQDN:8080/nova/v2/%\(tenant_id\)s \
  --internalurl http://$CONTROLLER_IP:8774/nova/v2/%\(tenant_id\)s \
  --adminurl http://$CONTROLLER_IP:8774/nova/v2/%\(tenant_id\)s
openstack endpoint create \
         network \
         --publicurl "https://$FQDN:8080/neutron" \
         --adminurl "http://$GATEWAY_IP:9696" \
         --internalurl "http://$GATEWAY_IP:9696"
openstack endpoint create \
  orchestration \
  --publicurl "https://$FQDN:8080/heat/v1/%(tenant_id)s" \
   --internalurl "http://$GATEWAY_IP:8004/v1/%(tenant_id)s" \
   --adminurl "http://$GATEWAY_IP:8004/v1/%(tenant_id)s"
openstack endpoint create \
  --publicurl "https://$FQDN:8080/cloudformation/v1" \
  --internalurl "http://$GATEWAY_IP:8000/v1" \
  --adminurl "http://$GATEWAY_IP:8000/v1" \
  --region RegionOne \
  cloudformation

openstack user set --password $ADMINPASS openstackservices
openstack user set --password $ADMINPASS stackadmin
openstack user set --password $ADMINPASS prvadmin
openstack user set --password $ADMINPASS alcesstack
openstack user set --password $ADMINPASS heat
