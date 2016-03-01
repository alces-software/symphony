################################################################################
# (c) Copyright 2007-2016 Alces Software Ltd                                   #
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
#!/bin/bash

echo "User's Email Address: "
read emailaddr

echo "Username: "
read username

echo "Group: "
read group

echo "Commands will be:"
echo -e '\n'
projectcreate=(openstack project create "--description=\"Private project for $username\"" $username)
#projectcreate="openstack project create --description=\"Private project for $username\" $username"
echo "${projectcreate[@]}"
usercreate="openstack user create --email=$emailaddr $username"
echo $usercreate
roleadduser="openstack role add --project=$username --user=$username user"
echo $roleadduser
roleaddproject="openstack role add --project=$group --user=$username user"
echo $roleaddproject
echo -e '\n'
echo "Are you sure you want to create this new openstack user?"
read sure
if [ -z $sure ]; then
   echo "No response - exiting"
   exit 1
elif [ $sure == 'Y' ] || [ $sure == 'y' ]; then
   "${projectcreate[@]}"
   $usercreate
   $roleadduser
   $roleaddproject
   exit 0
else
   echo "Quitting..."
   exit 1
fi
