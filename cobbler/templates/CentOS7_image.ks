# Generic EL6 Alces Build Template - 2008-2014 Alces Software Ltd 

#PRESCRIPT
$SNIPPET('kickstart_start')
# Enable installation monitoring
$SNIPPET('pre_anamon')

#PACKAGES
packages="
$SNIPPET('symphony/packages')
"; yum -y install $packages
#POSTSCRIPTS
$SNIPPET('log_ks_post')
$SNIPPET('symphony/hardhostfile')
$SNIPPET('symphony/firstrun')
$SNIPPET('symphony/yumupdate')
$SNIPPET('symphony/symphonyrepoinstall')
$SNIPPET('symphony/disablenetworkmanager')
$SNIPPET('symphony/installpuppet')
$SNIPPET('symphony/infiniband')
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

#Image networking changes
$SNIPPET('symphony/resolv')
