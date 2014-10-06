################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonydirector::customization (
  $role,
  $clientname,
  $install_directorkey,
  $install_syslog,
  $directorkey,
)
{

  file {'/etc/profile.d/symphony-director-prompt.sh':
    ensure=>present,
    mode=>0644,
    owner=>'root',
    group=>'root',
    content=>template('symphonydirector/customization/symphony-director-prompt.sh.erb')
  }

  package { 'augeas':
    ensure=>installed,
  }

  augeas {'sysconfig-selinux-disabled':
    context => "/files/etc/sysconfig/selinux",
    changes => "set SELINUX disabled",
  }

  if $install_directorkey {
    file { "/root/.ssh":
      ensure            =>  directory,
      owner             =>  'root',
      group             =>  'root',
      mode              =>  '0700',
    }
 
    ssh_authorized_key {'director_key':
      ensure          => present,
      name            => 'root',
      user            => 'root',
      type            => 'ssh-rsa',
      key             => $directorkey,
    }
  }
  if $role == 'slave' {
    if $install_syslog {
      file_line {"syslog-remote":
        path=>"/etc/rsyslog.conf",
        ensure=>present,
        line=>"*.* @symphony-director:514",
        notify=>Service['rsyslog'],
      }
      service {"rsyslog":
        ensure=>'running',
        enable=>true,
      }
    }
  }
}
