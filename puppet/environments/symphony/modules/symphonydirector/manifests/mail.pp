################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonydirector::mail (
  $role,
  $install_postfix,
  $externalrelay,
  $maildomain,
  $mailfrom,
)
{
  if $install_postfix {
    package { 'postfix': 
      ensure => 'installed',
    }
    service { 'postfix':
      enable => true,
      ensure => 'running'
    }
    if $role == 'master' {
      file {'/etc/postfix/main.cf':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template('symphonydirector/mail/master_main.cf.erb'),
        notify=>Service['postfix']
      }
      file {'/etc/postfix/master-rewrite-sender':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template('symphonydirector/mail/master-rewrite-sender.erb'),
        notify=>Service['postfix']
      } 
    } else {
      file {'/etc/postfix/main.cf':
        ensure=>present,
        mode=>0644,
        owner=>'root',
        group=>'root',
        content=>template('symphonydirector/mail/slave_main.cf.erb'),
        notify=>Service['postfix']
      }
    }
  }
}
