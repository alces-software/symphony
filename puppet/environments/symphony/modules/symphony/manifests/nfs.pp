################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class symphony::nfs (
  $nfsimports,
)
{ 
  package { 'nfs-utils':
    ensure=>'installed'
  }

  if $nfsimports != undef {
     create_resources( symphony::nfs::fsimport, $nfsimports )
  }
  service {'rpcbind':
    enable=>'true',
    ensure=>'running',
    require=>Package['nfs-utils']
  }
}
