################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonydirector (
  #Client name - to be used throughout symphony
  $clientname = hiera('symphonydirector::clientname'),
  #Role (symphony-director is master, all else are slave)
  $role = $symphony_directorrole
)
{
  $masterdns = hiera('symphonymonitor::masterdns','symphony-monitor')
  class { 'symphonydirector::customization':
    role => $role,
    clientname => $clientname,
    install_directorkey => hiera('symphonydirector::customization::install_directorkey',true),
    install_syslog => hiera('symphonydirector::customization::install_syslog',true),
    #SSH public key for root@symphony-director
    directorkey => hiera('symphonydirector::customization::directorkey')
  }

  class { 'symphonydirector::time': 
    install_ntp => hiera('symphonydirector::time::install_ntp',true),
    additionalntpservers => hiera('symphonydirector::time::additionalntpservers',[]),
    role => $role,
  }

  class { 'symphonydirector::mail':
    role => $role,
    install_postfix => hiera('symphonydirector::mail::install_postfix',true),
    externalrelay => hiera('symphonydirector::mail::externalrelay'),
    maildomain => hiera('symphonydirector::mail::maildomain'),
    mailfrom => hiera('symphonydirector::mail::mailfrom'),
  }
    
}
