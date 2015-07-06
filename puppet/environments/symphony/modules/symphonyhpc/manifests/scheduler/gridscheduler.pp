################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonyhpc::scheduler::gridscheduler (
  $role,
)
{
user{'geadmin':
    uid=>'360',
    gid=>'360',
    shell=>'/sbin/nologin',
    home=>'/opt/service/gridscheduler/2011.11p1_155',
    ensure=>present,
    require=>Group['geadmin'],
  }
  group{'geadmin':
    ensure=>present,
    gid=>'360',
  }
  if $role == 'master' {
    package {'alces-gridscheduler':
      ensure=>installed
    }
    service {'qmaster.alces-gridscheduler':
      enable=>true,
      require=>Package['alces-gridscheduler']
    }
    file {'/var/lib/symphony/hpc/':
      ensure=>directory,
      mode=>755,
      owner=>'root',
      group=>'root'
    }
    file {'/var/lib/symphony/hpc/share/':
      ensure=>directory,
      mode=>755,
      owner=>'root',
      group=>'root'
    }
    file {'/var/lib/symphony/hpc/share/alces-gridscheduler-config.tgz':
      ensure=>present,
      mode=>600,
      owner=>'root',
      group=>'root',
      source=>'puppet:///modules/symphonyhpc/scheduler/alces-gridscheduler-config.tgz',
      require=>File['/var/lib/symphony/hpc/share']
    }
    file {'/var/lib/symphony/hpc/bin/':
      ensure=>directory,
      mode=>755,
      owner=>'root',
      group=>'root'
    }
    file {'/var/lib/symphony/hpc/bin/init-gridscheduler.sh':
      ensure=>present,
      mode=>700,
      owner=>'root',
      group=>'root',
      source=>'puppet:///modules/symphonyhpc/scheduler/init-gridscheduler.sh',
      require=>File['/var/lib/symphony/hpc/bin/']
    }
    exec {'unpack-gridscheduler-config':
      command=>'tar -zxvf /var/lib/symphony/hpc/share/alces-gridscheduler-config.tgz -C /',
      creates=>'/var/spool/gridscheduler',
      require=>File['/var/lib/symphony/hpc/share/alces-gridscheduler-config.tgz']
    }
  }
  else {
    file{'/etc/rc.d/init.d/execd.alces-gridscheduler':
      ensure=>present,
      owner=>'root',
      group=>'root',
      mode=>'744',
      source=>'puppet:///modules/symphonyhpc/scheduler/execd.alces-gridscheduler',
    }
    service{'execd.alces-gridscheduler':
      enable=>true,
      require=>File['/etc/rc.d/init.d/execd.alces-gridscheduler']
    }
  }
}
