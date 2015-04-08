################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonymonitor::nagios (
  $role,
  $profile,
  $install_nagios,
  $install_nrpe = true,
)
{
  if $install_nagios {
    package {'nrpe':
              ensure=>installed
            }

    package {'MegaCli':
              ensure=>installed
            }

    file {'/etc/nagios/nrpe.cfg':
          ensure=>present,
          mode=>0644,
          owner=>'nrpe',
          group=>'nrpe',
          content=>symphonytemplate("symphonymonitor/nagios/nrpe.erb"),
          require=>Package['nrpe'],
          notify=>Service['nrpe']
    }
    file {'/etc/nrpe.d/nrpe-local.cfg':
	  ensure=>present,
          mode=>0644,
          owner=>'nrpe',
          group=>'nrpe',
          content=>symphonytemplate("symphonymonitor/nagios/nrpe-local.erb"),
          require=>Package['nrpe'],
          notify=>Service['nrpe'],
	  replace=>false,
    }

    service {'nrpe':
             enable=>'true',
             ensure=>'running',
             require=>Package['nrpe']
    }
    user {'nrpe':
      #groups=>['nrpe'],
      require=>Package['nrpe'],
    }

  } else {
    #service {'nrpe':
    #         enable=>'false',
    #         ensure=>'stopped'
    #}
  }
  if $install_nagios {
    if $role == 'master' {
      user {'nagios':
        groups=>['apache'],
        require=>Package['nagios'],
      }
      package {'nagios':
                ensure=>installed
              }
      package {'nagios-plugins':
               ensure=>installed
              }
      package {'nagios-plugins-all':
                ensure=>installed
              }
      package {'httpd':
               ensure=>installed
              }
      service {'nagios':
               enable=>'true',
               ensure=>'running',
               require=>Package['nagios']
              }
      service {'httpd':
               enable=>'true',
               ensure=>'running',
               require=>Package['httpd'],
               }
      file {'/etc/nagios/cgi.cfg':
            ensure=>present,
            mode=>0644,
            owner=>'nagios',
            group=>'nagios',
            content=>template("symphonymonitor/nagios/cgi.cfg.erb"),
            require=>Package['nagios'],
            notify=>Service['nagios']
       }
       file {'/etc/nagios/nagios.cfg':
	     mode=>0644,
             owner=>'nagios',
             group=>'nagios',
             content=>symphonytemplate("symphonymonitor/nagios/nagios.cfg.erb"),
             require=>Package['nagios'],
             notify=>Service['nagios']
       }
       file {'/etc/nagios/objects/cluster.cfg':
             mode=>0644,
             owner=>'nagios',
             group=>'nagios',
             content=>symphonytemplate("symphonymonitor/nagios/cluster.cfg.erb"),
             require=>Package['nagios'],
             notify=>Service['nagios']
       }

       # Separate local configuration files - do not overwrite if they already exist
       file {'/etc/nagios/objects/alces':
	     ensure=>directory,
	     mode=>0755,
	     owner=>'nagios',
             group=>'nagios',
       }

       file {'/etc/nagios/objects/alces/alces-hostgroups.cfg':
             ensure=>present,
             mode=>0644,
             owner=>'nagios',
             group=>'nagios',
             content=>symphonytemplate("symphonymonitor/nagios/alces-hostgroups.cfg.erb"),
             require=>Package['nagios'],
             notify=>Service['nagios'],
             replace=>false,
       }
       file {'/etc/nagios/objects/alces/alces-hosts.cfg':
             ensure=>present,
             mode=>0644,
             owner=>'nagios',
             group=>'nagios',
             content=>symphonytemplate("symphonymonitor/nagios/alces-hosts.cfg.erb"),
             require=>Package['nagios'],
             notify=>Service['nagios'],
             replace=>false,
       }
       file {'/etc/nagios/objects/alces/alces-services.cfg':
             ensure=>present,
             mode=>0644,
             owner=>'nagios',
             group=>'nagios',
             content=>symphonytemplate("symphonymonitor/nagios/alces-services.cfg.erb"),
             require=>Package['nagios'],
             notify=>Service['nagios'],
             replace=>false,
       }

       file {'/etc/nagios/objects/commands.cfg':
             mode=>0644,
             owner=>'nagios',
             group=>'nagios',
             content=>symphonytemplate("symphonymonitor/nagios/commands.cfg.erb"),
             require=>Package['nagios'],
             notify=>Service['nagios']
       }
       file {'/etc/nagios/objects/contacts.cfg':
             mode=>0644,
             owner=>'nagios',
             group=>'nagios',
             content=>template("symphonymonitor/nagios/contacts.cfg.erb"),
             require=>Package['nagios'],
             notify=>Service['nagios']
       }
       file {'/etc/nagios/objects/timeperiods.cfg':
             mode=>0644,
             owner=>'nagios',
             group=>'nagios',
             content=>template("symphonymonitor/nagios/timeperiods.cfg.erb"),
             require=>Package['nagios'],
             notify=>Service['nagios']
       }
       file {'/etc/httpd/conf.d/nagios.conf':
             mode=>0644,
             owner=>'apache',
             group=>'apache',
             content=>template("symphonymonitor/nagios/nagioshttpd.conf.erb"),
             require=>Package['httpd'],
             notify=>Service['httpd']
       }
       file {'/etc/cron.daily/symphonymonitor-ecc-check':
        ensure=>present,
        mode=>0755,
        owner=>'nagios',
        group=>'nagios',
        content=>template("symphonymonitor/nagios-crons/ecc-check.erb"),
        require=>Package['nagios'],
       }
       file {'/etc/cron.hourly/symphonymonitor-disk-check':
        ensure=>present,
        mode=>0755,
        owner=>'nagios',
        group=>'nagios',
        content=>template("symphonymonitor/nagios-crons/disk-check.erb"),
        require=>Package['nagios'],
       }

       file {'/etc/cron.hourly/symphonymonitor-ipmi-check':
        ensure=>present,
        mode=>0755,
        owner=>'nagios',
        group=>'nagios',
        content=>template("symphonymonitor/nagios-crons/ipmi-check.erb"),
        require=>Package['nagios'],
       }
    }
  }
}
