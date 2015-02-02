################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonyrepo::yum (
  $install_repoconfigs,
  $enablerepos
)
{
  if $install_repoconfigs {
    file {"/etc/yum.repos.d/symphony.repo":
      ensure=>present,
      mode=>0644,
      owner=>'root',
      group=>'root',
      replace=>'no',
      content=>template("symphonyrepo/yum/$symphony_operatingsystem_major.erb"),
      notify=>Exec['yumclean']
    }
    exec {"repoclean":
      command=>"find /etc/yum.repos.d -type f ! -iwholename /etc/yum.repos.d/symphony.repo -exec rm {} \\;",
      subscribe=>File['/etc/yum.repos.d/symphony.repo'],
      refreshonly=>true
    }

    exec {"yumclean":
      command=>"yum clean all",
      refreshonly=>true
    }
    package {'yum-plugin-priorities':
      require=>File['/etc/yum.repos.d/symphony.repo'],
      ensure=>installed,
    }  
    symphonyrepo::yum::enablerepo { $enablerepos: 
      require=>File['/etc/yum.repos.d/symphony.repo']
    }
  }
}
