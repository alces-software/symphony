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
  $role = $symphony_monitorrole,
  #profile - profile name from symphony base modules
  $profile = 'generic'
)
{
  $masterdns = hiera('symphonymonitor::masterdns','symphony-monitor')
  class { 'symphonymonitor::ganglia':
    install_ganglia => hiera('symphonymonitor::ganglia::install_ganglia',true),
    masterdns => $masterdns,
    clientname => $clientname,
    role => $role,
  }

  class { 'symphonymonitor::nagios':
    install_nagios=> hiera('symphonymonitor::nagios::install_nagios',true),
    role => $role,
    profile => $profile,
  }
}
