module Puppet::Parser::Functions
  require 'erb'

  newfunction(:symphonytemplate, :type => :rvalue, :doc => <<-EOD
    A Puppet function that tries implements symphony dynamic template finder, appending various dynamic parameters to the end of the filename as a suffix
    1) $::hostname
    2) $::fqdn
    3) $::symphony_machinetype
    4) $profile
    5) $role
    6) no suffix

      class ssh::config {

        file { "/etc/ssh/sshd_config" :
          ensure  => present,
          mode    => '0600',
          content => symphonytemplate( "ssh/sshd.conf.erb"),
        }

      }

  EOD
  ) do |args|
    contents    = nil
    environment = self.compiler.environment
    filename	= args[0]
    suffixes    = [lookupvar('hostname'),lookupvar('fqdn'),lookupvar('symphony_machinetype'),lookupvar('profile'),lookupvar('role')]
    sources   = []

    suffixes.each do |suffix|
      sources << "#{filename}.#{suffix}"
    end
    sources << filename

    sources.each do |file|
      Puppet.debug("Looking for #{file} in #{environment}")
      if filename = Puppet::Parser::Files.find_template(file, environment)
        wrapper = Puppet::Parser::TemplateWrapper.new(self)
        wrapper.file = file

        begin
          contents = wrapper.result
        rescue => detail
          raise Puppet::ParseError, "Failed to parse template %s: %s" % [file, detail]
        end

        break
      end
    end

    raise Puppet::ParseError, "multi_source_template: No match found for files: #{sources.join(', ')}" if contents == nil

    contents
  end
end
