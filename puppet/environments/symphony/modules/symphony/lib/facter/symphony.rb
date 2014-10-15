################################################################################
###
### Alces HPC Software Stack - Puppet configuration files
### Copyright (c) 2008-2014 Alces Software Ltd
###
#################################################################################
require 'yaml'

Facter.add("symphony_operatingsystem") do
  setcode do
    "#{Facter.value('os')['name']}#{Facter.value('os')['release']['major']}.#{Facter.value('os')['release']['minor']}"
  end
end

Facter.add("symphony_directorrole") do
  setcode do
    if Facter.value('hostname') == 'symphony-director'
      'master'
    else
      'slave'
    end
  end
end

Facter.add("symphony_reporole") do
  setcode do
    if Facter.value('hostname') == 'symphony-repo'
      'master'
    else
      'slave'
    end
  end
end

Facter.add("symphony_monitorrole") do
  setcode do
    if Facter.value('hostname') == 'symphony-monitor'
      'master'
    else
      'slave'
    end
  end
end

Facter.add("symphony_machinetype") do
  setcode do
    'generic'
  end
end
