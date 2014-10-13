################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonydirector::time (
  $install_ntp,
  $additionalntpservers
)
{

  include 'ntp::params'
  if $install_ntp {
    class { '::ntp':
      servers => concat($additionalntpservers,$ntp::params::servers),
    }
  }
}
