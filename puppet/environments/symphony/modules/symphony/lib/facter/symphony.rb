################################################################################
###
### Alces HPC Software Stack - Puppet configuration files
### Copyright (c) 2008-2014 Alces Software Ltd
###
#################################################################################
require 'yaml'

def symphony_operating_system
  if File::exists? '/etc/redhat-release'
    if ! File::read('/etc/redhat-release').to_s.match('ComputeNode').nil?
      val={:name=>"RHELCOMPUTENODE",:major=>Facter.value('os')['release']['major'],:minor=>Facter.value('os')['release']['minor']}
    end
  end
    val||={:name=>Facter.value('os')['name'],:major=>Facter.value('os')['release']['major'],:minor=>Facter.value('os')['release']['minor']}
    val
end

Facter.add("symphony_operatingsystem") do
  setcode do
    os=symphony_operating_system
    "#{os[:name]}#{os[:major]}.#{os[:minor]}"
  end
end

Facter.add("symphony_operatingsystem_major") do
  setcode do
    os=symphony_operating_system
    "#{os[:name]}#{os[:major]}"
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
