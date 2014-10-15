#!/usr/bin/env ruby
################################################################################
# (c) Copyright 2007-2011 Alces Software Ltd                                   #
#                                                                              #
# HPC Cluster Toolkit                                                          #
#                                                                              #
# This file/package is part of the HPC Cluster Toolkit                         #
#                                                                              #
# This is free software: you can redistribute it and/or modify it under        #
# the terms of the GNU Affero General Public License as published by the Free  #
# Software Foundation, either version 3 of the License, or (at your option)    #
# any later version.                                                           #
#                                                                              #
# This file is distributed in the hope that it will be useful, but WITHOUT     #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License #
# for more details.                                                            #
#                                                                              #
# You should have received a copy of the GNU Affero General Public License     #
# along with this product.  If not, see <http://www.gnu.org/licenses/>.        #
#                                                                              #
# For more information on Alces Software, please visit:                        #
# http://www.alces-software.org/                                               #
#                                                                              #
################################################################################
class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end
module Alces
  class NagiosCheck
    OK,WARN,CRIT,UNKNOWN = 0,1,2,3
    OK_STR      = "OK"
    WARN_STR    = "WARNING"
    CRIT_STR    = "CRITICAL"
    UNKNOWN_STR = "UNKNOWN"

    attr_reader :exit_code
    attr_reader :options
    attr_writer :exit_str
    attr_accessor :perfdata, :outputdata

    def initialize
      @exit_code  = OK
      @exit_str   = ""
      @perfdata   = ""
      @outputdata = ""
      @options={}
      parse_options
      execute
    end

    def exit_str
      str = case @exit_code
        when OK   then OK_STR
        when WARN then WARN_STR
        when CRIT then CRIT_STR
        else           UNKNOWN_STR
      end

      str += " - " + @outputdata if @outputdata != ""
      str += " | " + @perfdata if @perfdata != ""
      return str
    end

    def execute
      @outputdata << "Incorrect plugin, please override execute"
      self.exit_code=CRIT
    end

    def option(key)
      self.options[key.to_s]
    end

    # set the exit code based on the warn_range and crit_range
    def set_exit_code ( value, warn_range, crit_range )
      result = OK
      result = WARN if range_match(value.to_i, warn_range)
      result = CRIT if range_match(value.to_i, crit_range)
      self.exit_code = result
      return result
    end

    def required_options(required_options)
      required_options.each do |req|
        required_option(req)
      end
    end

    def required_option(required_option)
      respond!(WARN,"Missing required option: '#{required_option.to_s.downcase}'") unless self.options.has_key? required_option.to_s.downcase
    end

    # only sets the exit code if it is worse than the current exit code
    def exit_code=(exit_code)
      if exit_code > @exit_code
        if exit_code == UNKNOWN && @exit_code != OK
          # WARN and CRIT are higher priority than UNKNOWN
          return
        end
        @exit_code = exit_code
      end
    end

    def respond!(exit_code=nil,outputdata=nil)
      self.exit_code=exit_code unless exit_code.nil?
      self.outputdata << outputdata unless outputdata.nil?
      STDOUT.puts self.exit_str
      exit self.exit_code
    end

  protected
    # returns true if value is within range
    #10       < 0 or > 10, (outside the range of {0 .. 10})
    #10:      < 10, (outside {10 .. ∞})
    #~:10     > 10, (outside the range of {-∞ .. 10})
    # 10:20   < 10 or > 20, (outside the range of {10 .. 20})
    # @10:20  ≥ 10 and ≤ 20, (inside the range of {10 .. 20})
    def range_match ( value, range )
      return (value < 0 || value > range) if range.class != String

      result = false
      negate = (range =~ /^@(.*)/)
      range  = $1 if negate
      if range =~ /^(\d+)$/
        result = (value < 0 || value > $1.to_i)
      # untested from here to the end of the function
      elsif range =~ /^(\d+):[~]?$/
        result = (value < $1.to_i)
      elsif range =~ /^~:(\d+)$/
        result = (value > $1.to_i)
      elsif range =~ /^(\d+):(\d+)$/
        result = (value > $1.to_i && value < $2.to_i)
      end
      return negate ? !result : result
    end

    private

    def parse_options
      ARGV.each do |option|
        k,v=option.split("=")
        respond!(CRIT,"Invalid options passed to the plugin") if k.to_s.empty?
        (@options||={})[k]=v
      end
    end
  end
end
