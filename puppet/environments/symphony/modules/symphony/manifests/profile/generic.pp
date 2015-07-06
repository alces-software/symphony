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
  class { 'symphony':
    stage=>configure,
  }
  class { 'symphonyrepo': 
    stage=>init, 
  }
  class { 'symphonydirector':
    stage=>configure,
  }
  class { 'symphonymonitor':
    profile=>$profile,
    stage=>configure,
  }
  class { 'symphonyhpc':
    stage=>configure,
  }
}
