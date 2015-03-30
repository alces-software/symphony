################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
define symphony::nfs::fsimport (
  $source=$title,
  $target,
  $options="intr,rsize=32768,wsize=32768,_netdev",
)
{
  exec { "create_mountdir_${target}":
    command => "mkdir -p ${target}",
    creates => $target,
    before=>[File["dir-$target"]]
  }
  file { "dir-${target}":
    path=>$target,
    ensure=>'directory'
  }
  mount { "mount-${source}":
    require=>[File["dir-${target}"],Package['nfs-utils']],
    name=>$target,
    device=>$source,
    dump=>0,
    pass=>0,
    options=>$options,
    fstype=>"nfs",
    ensure=>"mounted"
  }
}
