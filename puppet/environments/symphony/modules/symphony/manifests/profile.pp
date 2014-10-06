################################################################################
##
## Alces HPC Software Stack - Puppet configuration files
## Copyright (c) 2008-2013 Alces Software Ltd
##
################################################################################
class symphony::profile
{
  stage {'init': before=>Stage['install']}
  stage {'install': before=>Stage['configure']}
  stage {'configure': before=>Stage['main']}
  Stage['main'] -> Stage['final']
  stage {'final':}
}
