################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonyrepo (
  #Client name - to be used throughout symphony
  $clientname = $symphonydirector::clientname,
  #role - master or slave
  $role = $symphony_reporole
)
{
  $masterdns = hiera('symphonymonitor::masterdns','symphony-repo')
  class { 'symphonyrepo::yum':
    install_repoconfigs => hiera('symphonyrepo::yum::install_repoconfigs',true),
    enablerepos => hiera('symphonyrepo::yum::enable_symphonyrepos',[])
    
  }
}
