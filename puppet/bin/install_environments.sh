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
SYMPHONY_HOME=/var/lib/symphony/
PUPPET_ENV=/etc/puppet/environments

if [ -d $PUPPET_ENV ]; then
  echo "Installing symphony puppet environments to $PUPPET_ENV"
  if [ -d $PUPPET_ENV/symphony ]; then 
    echo "Exisiting files detected - backing up"
    mv -v $PUPPET_ENV/symphony $PUPPET_ENV/symphony.$$.`date +"%m%d%Y"`
   echo DONE
  fi
  ln -snf $SYMPHONY_HOME/puppet/environments/symphony $PUPPET_ENV/.
  chown puppet:puppet -R $PUPPET_ENV
  #(cd $PUPPET_ENV/symphony && git init && git add * && git commit -a -m 'Initial commit')
  echo DONE
fi
