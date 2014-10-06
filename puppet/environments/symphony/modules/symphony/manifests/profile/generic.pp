################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class symphony::profile::generic (
) inherits ::symphony::profile
{
  $profile='generic'
  class { 'symphonyrepo': 
    stage=>init, 
  }
  class { 'symphonydirector':
    stage=>configure,
  }
}
