# Generic EL6 Alces Build Template - 2008-2014 Alces Software Ltd 

#MISC
text
reboot
skipx
install

#SECURITY
firewall --enabled
firstboot --disable
selinux --disabled

#AUTH
auth  --useshadow  --enablemd5
rootpw --iscrypted $default_password_crypted

#LOCALIZATION
keyboard uk
lang en_GB
timezone  Europe/London

#REPOS
url --url=$url
$yum_repo_stanza

#DISK
%include /tmp/disk.part

#PRESCRIPT
%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
$SNIPPET('symphony/disk')
%end

#PACKAGES
%packages --ignoremissing
$SNIPPET('func_install_if_enabled')
$SNIPPET('symphony/packages')
%end

#POSTSCRIPTS
%post --nochroot
$SNIPPET('log_ks_post_nochroot')
$SNIPPET('symphony/fixtime')
%end
%post
$SNIPPET('log_ks_post')
$SNIPPET('symphony/hardhostfile')
$SNIPPET('symphony/firstrun')
$SNIPPET('symphony/yumupdate')
$SNIPPET('symphony/symphonyrepoinstall')
$SNIPPET('symphony/disablenetworkmanager')
$SNIPPET('symphony/installpuppet')
$SNIPPET('symphony/infiniband')
$SNIPPET('symphony/ipmi')
$SNIPPET('symphony/scrubifcfg')
# Start yum configuration 
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('func_register_if_enabled')
$SNIPPET('download_config_files')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')
$SNIPPET('symphony/enrollipa')
$SNIPPET('symphony/sitescriptwrapper')
$SNIPPET('symphony/alceshpc')
$SNIPPET('symphony/clusterware.el7')
$SNIPPET('symphony/lustre')
$SNIPPET('symphony/installnova')
$SNIPPET('symphony/profile')
# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps (before puppet run, as it will run the cobbler post scripts to sign cert)
$SNIPPET('kickstart_done')
# End final steps
$SNIPPET('symphony/runpuppet')
#Do this late as possible it might mess with resolv.conf
$SNIPPET('post_install_network_config')
$SNIPPET('symphony/finalnetworkconfig')
%end
