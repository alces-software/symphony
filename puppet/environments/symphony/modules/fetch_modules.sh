#!/bin/bash
################################################################################
# (c) Copyright 2007-2014 Alces Software Ltd                                   #
#                                                                              #
# Symphony Software Toolkit                                                    #
#                                                                              #
# This file/package is part of Symphony                                        #
#                                                                              #
# Symphony is free software: you can redistribute it and/or modify it under    #
# the terms of the GNU Affero General Public License as published by the Free  #
# Software Foundation, either version 3 of the License, or (at your option)    #
# any later version.                                                           #
#                                                                              #
# Symphony is distributed in the hope that it will be useful, but WITHOUT      #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License #
# for more details.                                                            #
#                                                                              #
# You should have received a copy of the GNU Affero General Public License     #
# along with Symphony.  If not, see <http://www.gnu.org/licenses/>.            #
#                                                                              #
# For more information on the Symphony Toolkit, please visit:                  #
# http://www.alces-software.org/symphony                                       #
#                                                                              #
################################################################################

check () {
  if ! [ -d $1/.git ]; then
    echo "Failed to clone $1 module" >&2
    exit 1
  fi
}

cd `dirname $0`

git clone https://github.com/ste78/puppet-multitemplate.git multitemplate
check multitemplate || exit 1
git clone https://github.com/puppetlabs/puppetlabs-stdlib.git -b 4.3.2 stdlib
check stdlib || exit 1
git clone https://github.com/puppetlabs/puppetlabs-ntp.git -b 3.2.1 ntp
check ntp || exit 1
git clone https://github.com/jpopelka/puppet-firewalld.git -b v0.2.2 firewalld
check firewalld || exit 1
git clone https://github.com/jhoblitt/puppet-ganglia -b v1.3.0 ganglia
check ganglia || exit 1
