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

SYMPHONY_REPO_URL="http://symphony-repo/configs/"

cd `dirname $0`
if [ ! -d templates/yum ]; then
  mkdir templates/yum
fi
curl $SYMPHONY_REPO_URL/centos/7/yum-repos.conf > templates/yum/CentOS7.erb
curl $SYMPHONY_REPO_URL/centos/6/yum-repos.conf > templates/yum/CentOS6.erb
curl $SYMPHONY_REPO_URL/rhel/6/yum-repos.conf > templates/yum/RHEL6.erb
curl $SYMPHONY_REPO_URL/rhelcomputenode/6/yum-repos.conf > templates/yum/RHELCOMPUTENODE6.erb
curl $SYMPHONY_REPO_URL/sl/6/yum-repos.conf > templates/yum/Scientific6.erb
curl $SYMPHONY_REPO_URL/sl/7/yum-repos.conf > templates/yum/Scientific7.erb
chown puppet:puppet -R templates/yum

