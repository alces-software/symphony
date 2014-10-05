################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonydirector (
  #Client name - to be used throughout symphony
  $clientname = hiera('symphonydirector::clientname'),
)
{
  class { 'symphonydirector::customization':
    clientname => $clientname,
    install_directorkey => hiera('symphonydirector::customization::install_directorkey',true),
    #SSH public key for root@symphony-director
    directorkey => hiera('symphonydirector::customization::directorkey')
  }
}
