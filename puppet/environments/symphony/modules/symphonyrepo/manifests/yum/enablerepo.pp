################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
define symphonyrepo::yum::enablerepo (
  $reponame = $title
)
{
  augeas {"enablerepo-$title":
    context => "/files/etc/yum.repos.d/symphony.repo/$reponame/",
    changes => "set enabled 1",
  }  
}
