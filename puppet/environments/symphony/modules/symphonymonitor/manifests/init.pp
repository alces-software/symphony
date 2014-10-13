################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonymonitor (
  #Client name - to be used throughout symphony
  $clientname = $symphonydirector::clientname,
  #role - master or slave
  $role = $symphony_monitorrole
)
{
  class { 'symphonymonitor::ganglia':
    install_ganglia => hiera('symphonymonitor::ganglia::install_ganglia',true),
    clientname => $clientname,
    role => $role,
  }
}
