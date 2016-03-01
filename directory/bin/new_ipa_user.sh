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
#!/bin/bash

ipacheck='ipa user-find'
$ipacheck &>/dev/null ; ipastatus=$?
if [ "$ipastatus" -ge "1" ]
then
   echo "Could not run test ipa command - have you got a kerberos ticket? Run kinit admin..."
   exit 1
fi


gidnumber=`ipa group-find clusterusers | grep GID | awk '{print $2}'`

echo "User's First Name: "
read firstname

echo "User's Last Name: "
read lastname

echo "User's Email Address: "
read emailaddr

echo "Username: "
read username

echo "Group: "
read group

echo "GID Number [$gidnumber]: "
read gidnumberalt
if [ -z $gidnumberalt ]; then
   echo "Using default GID of $gidnumber"
else
   gidnumber=$gidnumberalt
fi

echo "Should this user be a member of the cloudusers group? [y/n]"
read clouduser
if [ -z $clouduser ]; then
   echo "No response - exiting"
   exit 1
fi
echo -e '\n'
echo "Command will be:"
echo -e '\n'
addusercommand="ipa user-add --first=$firstname --last=$lastname --email=$emailaddr --random --gidnumber=$gidnumber $username"
echo $addusercommand
addgroupdept="ipa group-add-member $group --users $username"
echo $addgroupdept
if [ $clouduser == 'Y' ] || [ $clouduser == 'y' ]; then
  addgroupcloud="ipa group-add-member cloudusers --users $username"
  echo $addgroupcloud
fi
echo -e '\n'
echo "Are you sure you want to create this new user?"
read sure
if [ -z $sure ]; then
   echo "No response - exiting"
   exit 1
elif [ $sure == 'Y' ] || [ $sure == 'y' ]; then
   $addusercommand
   echo -e '\n'
   $addgroupdept
   echo -e '\n'
   if [ $clouduser == 'Y' ] || [ $clouduser == 'y' ]; then
     $addgroupcloud
     echo -e '\n'
   fi
   exit 0
else
   echo "Quitting..."
   exit 1
fi
