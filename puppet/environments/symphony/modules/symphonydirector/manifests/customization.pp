################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonydirector::customization (
  $clientname,
  $install_directorkey,
  $directorkey
)
{
  file {'/etc/profile.d/symphony-director-prompt.sh':
    ensure=>present,
    mode=>0644,
    owner=>'root',
    group=>'root',
    content=>template('symphonydirector/customization/symphony-director-prompt.sh.erb')
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
}
