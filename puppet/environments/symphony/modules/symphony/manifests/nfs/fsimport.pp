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
  file { "dir-${target}":
    name=>$target,
    ensure=>'directory',
    owner=>'root',
    group=>'root',
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
