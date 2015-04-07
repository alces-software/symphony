
if [ -f $1 ]; then
  CONFIGFILE=$1
  NAME=$2
  IPQUAD3=$3
  IPQUAD4=$4
  BUILD_MAC=$5
fi

if ! [ -z $CONFIGFILE ]; then 
  . $CONFIGFILE
fi

if [ -z $NAME ]; then
  echo -n "Name: "; read NAME
fi
if [ -z $IPQUAD3 ]; then
  echo -n "IPQUAD 3: "; read IPQUAD3
fi
if [ -z $IPQUAD4 ]; then
  echo -n "IPQUAD 4: "; read IPQUAD4
fi

. `dirname $0`/config/site
. `dirname $0`/config/host

#reload config in case it uses variables set in primary configs
if ! [ -z $CONFIGFILE ] && [ -f $CONFIGFILE ]; then
  . $CONFIGFILE
fi

cobbler system add --name $NAME --hostname $NAME.$PRVDOMAIN --profile $PROFILE --name-servers-search "$SEARCHDOMAIN" --name-servers=10.78.254.1 --gateway=$GW

cobbler system edit --name $NAME --hostname $NAME.$PRVDOMAIN --profile $PROFILE --name-servers-search "$SEARCHDOMAIN" --name-servers=10.78.254.1 --gateway=$GW


#create bonds
for bond in $BONDS; do
  OPTIONS=$(echo $(eval echo \$${bond}OPTIONS))
  cobbler system edit --name $NAME --interface=$bond --interface-type=bond --bonding-opts="$OPTIONS"
  SLAVES=$(echo $(eval echo \$${bond}SLAVES))
  for slave in $SLAVES; do
    cobbler system edit --name $NAME --interface $slave --interface-type=bond_slave --interface-master=$bond
  done
done

#create bridges
for bridge in $BRIDGES; do
  OPTIONS=$(echo $(eval echo \$${bridge}OPTIONS))
  if [ -z $OPTIONS ]; then
    OPTIONS="stp=no"
  fi
  cobbler system edit --name $NAME --interface $bridge --interface-type=bridge --bridge-opts="$OPTIONS"
  SLAVES=$(echo $(eval echo \$${bridge}SLAVES))
  for slave in $SLAVES; do
    cobbler system edit --name $NAME --interface $slave --interface-type=bridge_slave --interface-master=$bridge
  done
done

cobbler system edit --name $NAME --interface $BUILD_INT --dns-name=$NAME.$BUILDDOMAIN --ip-address=$IPBUILD --netmask=$BUILDNETMASK --static=true 
if ! [ -z "$BUILD_MAC" ]; then
  echo $BUILD_MAC
  cobbler system edit --name $NAME --interface $BUILD_INT --mac="$BUILD_MAC"
fi

if ! [ -z $PRV_INT ]; then
  cobbler system edit --name $NAME --interface $PRV_INT --dns-name=$NAME.$PRVDOMAIN --ip-address=$IPPRV --netmask=$PRVNETMASK --static=true
  if ! [ -z $PRV_ROUTES ]; then
    cobbler system edit --name $NAME --interface $PRV_INT --static-routes="$PRV_ROUTES"
  fi
fi
if ! [ -z $MGT_INT ]; then
  cobbler system edit --name $NAME --interface $MGT_INT --dns-name=$NAME.$MGTDOMAIN --ip-address=$IPMGT --netmask=$MGTNETMASK --static=true
fi
if ! [ -z $DMZ_INT ]; then
  cobbler system edit --name $NAME --interface $DMZ_INT --dns-name=$NAME.$DMZDOMAIN --ip-address=$IPDMZ --netmask=$DMZNETMASK --static=true
fi

cobbler system edit --name $NAME --netboot=1 --in-place --ksmeta="disklayout='$DISKLAYOUT' disk1='$DISK'"
if [ "$MACHINETYPE" == "vm" ]; then
  cobbler system edit --name $NAME --in-place --ksmeta="serial='ttyS0,115200n8'"
else
  cobbler system edit --name $NAME --in-place --ksmeta="serial='ttyS1,115200n8'"
fi

if ! [ -z $DISK2 ]; then
  cobbler system edit --in-place --name $NAME --ksmeta="disk2=$DISK2"
fi

# if using IPA Directory Server
if ! [ -z $IDMIP ]; then
  cobbler system edit --name $NAME --name-servers=$IDMIP
  cobbler system edit --name $NAME --in-place --ksmeta="ipa_domain=$DOMAIN ipa_realm=$REALM ipa_server=$IDM ipa_password=$IPAPASSWORD"
fi

if [ $HOSTTYPE == "hw" ]; then
  # bmc
  cobbler system edit --name $NAME --power-type=ipmilan --power-address=$IPBMC --power-user="$IPMIUSER" --power-pass="$IPMIPASSWORD"
  cobbler system edit --name $NAME --interface bmc --dns-name=$NAME.bmc.$MGTDOMAIN --ip-address=$IPBMC
  cobbler system edit --name $NAME --in-place --ksmeta "ipmiset=true ipminetmask='$MGTNETMASK' ipmigateway='$GWMGT' ipmilanchannel=1 ipmiuserid=2"
fi

# infiniband adapter?
if ! [ -z $IB_INT ]; then
  cobbler system edit --name $NAME --interface $IB_INT --dns-name=$NAME.$IBDOMAIN --ip-address=$IPIB --netmask=$IBNETMASK --static=true
fi

cobbler system report --name $NAME
