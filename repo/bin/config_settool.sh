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

AVAILABLE_GROUPS="centos6 el6other centos7.0 el7other el6symphony el7symphony rhel6 rhelhpcnode6 el6alceshpc el7alceshpc sl6 sl7 el7rdojuno el7rdokilo"

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIGFILE="${BASEDIR}/../etc/yum-sources.conf"

GROUP=$1
SOURCE=$2

SOURCE=`echo $SOURCE | awk '{print tolower($0)}'`
GROUP=`echo $GROUP | awk '{print toupper($0)}'`

source $CONFIGFILE 

#TODO - Create file that logs local or live state and only change status of yum.conf dependant on which repo is selected and where it is set to.

if [ -z $GROUP ]; then
  echo "Please specify group, Available Groups: [$AVAILABLE_GROUPS]" >&2
  exit 1
fi

if [ "$SOURCE" == "status" ]; then
    echo "Repository $GROUP is currently ${!GROUP}"
    exit
fi

if [ -z $SOURCE ]; then
    echo "Please specify Repository source or use status to show current setting" >&2
    exit 1
fi

if [ "${!GROUP}" == "$SOURCE" ]; then
  echo "Source for Repository $GROUP is already set to $SOURCE!" >&2
  exit 1
fi


if [ -z "${!GROUP}" ]; then
    echo "Please specify valid group - $GROUP does not exist" >&2
    exit 1
fi
       
sed -i -e "s/^$GROUP.*$/$GROUP=$SOURCE/g" $CONFIGFILE
source $CONFIGFILE

echo "$GROUP is now set to ${!GROUP}"

echo "Now building writing configuration files..."
$SYMPHONY_HOME/repo/bin/write_configs.sh
