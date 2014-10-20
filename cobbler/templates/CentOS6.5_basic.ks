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
url --url=http://symphony-repo/pulp/repos/$tree/os/
$yum_repo_stanza

#NETWORK
$SNIPPET('network_config')

#DISK
bootloader --location=mbr
zerombr
clearpart --all --initlabel
autopart

#PRESCRIPT
%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')

#PACKAGES
%packages --ignoremissing
$SNIPPET('func_install_if_enabled')
$SNIPPET('symphony/packages')

#POSTSCRIPTS
%post --nochroot
$SNIPPET('log_ks_post_nochroot')
%post
$SNIPPET('log_ks_post')
$SNIPPET('symphony/symphonyrepoinstall')
$SNIPPET('symphony/disablenetworkmanager')
$SNIPPET('symphony/installpuppet')
$SNIPPET('symphony/hardhostfile')
# Start yum configuration 
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('func_register_if_enabled')
$SNIPPET('download_config_files')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')
# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('kickstart_done')
# End final steps
$SNIPPET('symphony/runpuppet')
