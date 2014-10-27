################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonydirector::time (
  $install_ntp,
  $role,
  $additionalntpservers
)
{
  include 'ntp::params'
  if $role == 'master' {
    if $install_ntp {
      class { '::ntp':
        servers => concat($additionalntpservers,$ntp::params::servers),
        iburst_enable => true
      }
    } 
  } else {
    if $install_ntp {
      class { '::ntp':
        servers => concat($additionalntpservers,$ntp::params::servers),
        iburst_enable => true
      }
    }  
  }
}
