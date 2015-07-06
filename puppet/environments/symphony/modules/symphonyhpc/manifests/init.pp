################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonyhpc (
  #Client name - to be used throughout symphony
  $clientname = hiera('symphonydirector::clientname'),
  #install grdischeduler
  $gridscheduler = hiera('symphonyhpc::scheduler::gridscheduler',false),
)
{
  if $gridscheduler {
    class { 'symphonyhpc::scheduler::gridscheduler':
      role => hiera('symphonyhpc::scheduler::gridscheduler::role','slave'),
    }
  }
    
}
