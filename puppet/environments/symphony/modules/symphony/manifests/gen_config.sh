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

#DOMAIN=mgt.symphony.local
#MAILRELAY=smtp.alces-software.com
#MAILFROM='test@alces-software.com'

#sed `dirname $0`/config/sample_hiera.yml \
#-e "s|%DIRECTORKEY%|`cat /root/.ssh/id_symphony.pub | cut -f 2 -d ' '`|g" \
#-e "s|%DOMAIN%|$DOMAIN|g" \
#-e "s|%MAILRELAY%|$MAILRELAY|g" \
#-e "s|%MAILFROM%|$MAILFROM|g" 

cat `dirname $0`/config/sample_hiera.yml
