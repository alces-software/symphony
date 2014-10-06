################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
filebucket { main: server => puppet }
Package { allow_virtual => true }
File { backup => main }
Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin" }

node default {
  class { 'symphony::profile::generic':
  }
}
