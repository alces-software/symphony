cd /etc/openvpn/easyrsa/
rm -rf keys
source ./vars
./clean-all
./pkitool --initca
./pkitool --server server
./build-dh
service openvpn@manage restart
