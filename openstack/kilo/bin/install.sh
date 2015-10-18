#!/bin/bash
cd /var/lib/symphony/openstack/kilo/
src=$1
if [ -z $src ]; then
  echo "Please specify source file" >&2
  exit 1
fi
dest=$2
if [ -z $dest ]; then
  echo "Please specify destination file" >&2
  exit 1
fi

if ! [ -f $src ]; then
  src=`dirname $0`/../$src
fi

if ! [ -f $src ]; then
  echo "Can't find source file $src" >&2
  exit 1
fi

#Source the vars
. `dirname $0`/vars


if ! [ -f "${dest}.bak" ]; then
  cp -v $dest "${dest}.bak"
else
  cp -v $dest "${dest}.bak.`date +%Y%m%d%H%M%S`"
fi 

sed $src \
-e "s/%CLUSTER%/$CLUSTER/g" \
-e "s/%CONTROLLER_IP%/$CONTROLLER_IP/g" \
-e "s/%CONTROLLER_PUBLICIP%/$CONTROLLER_PUBLICIP/g" \
-e "s/%GATEWAY_IP%/$GATEWAY_IP/g" \
-e "s/%STORAGE_IP%/$STORAGE_IP/g" \
-e "s/%ADMINPASS%/$ADMINPASS/g" \
-e "s/%FQDN%/$FQDN/g" \
-e "s/%GLANCEUUID%/$GLANCEUUID/g" \
-e "s/%KEYSTONEADMINTOKEN%/$KEYSTONEADMINTOKEN/g" \
-e "s/%SERVICEUSERID%/$SERVICEUSERID/g" \
-e "s/%MY_IP%/$MY_IP/g" \
-e "s/%MY_FQDN%/$MY_FQDN/g" > $dest
