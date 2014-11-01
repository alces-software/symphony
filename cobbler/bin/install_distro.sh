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

AVAILABLE_GROUPS="centos6.5 centos7.0 rhel6 rhelcomputenode6"

GROUP=$1

if [ -z $GROUP ]; then
  echo "Please specify group, Available Groups: [$AVAILABLE_GROUPS]" >&2
  exit 1
fi

case $GROUP in
  centos6.5) 
    ;;
  rhel6)
    #Get distro files
    curl http://symphony-repo/static/rhel/6/boot/images/pxeboot/initrd.img > /var/lib/symphony/cobbler/distro_files/RHEL6_initrd
    curl http://symphony-repo/static/rhel/6/boot/images/pxeboot/vmlinuz > /var/lib/symphony/cobbler/distro_files/RHEL6_kernel
    #Create distro
    cobbler distro add --name RHEL6 --kernel=/var/lib/symphony/cobbler/distro_files/RHEL6_kernel --initrd=/var/lib/symphony/cobbler/distro_files/RHEL6_initrd --arch=x86_64 --ksmeta="tree=rhel/6" --breed redhat --os-version=rhel6 --kopts="syslog=@@server@@"
    #Create Profile
    cobbler profile add --name RHEL6 --distro RHEL6 --kickstart /var/lib/cobbler/kickstarts/symphony/RHEL6_basic.ks
    ;;
  rhelcomputenode6)
    #Get distro files
    curl http://symphony-repo/static/rhelcomputenode/6/boot/images/pxeboot/initrd.img > /var/lib/symphony/cobbler/distro_files/RHELCOMPUTENODE6_initrd
    curl http://symphony-repo/static/rhelcomputenode/6/boot/images/pxeboot/vmlinuz > /var/lib/symphony/cobbler/distro_files/RHELCOMPUTENODE6_kernel
    #Create distro
    cobbler distro add --name RHELCOMPUTENODE6 --kernel=/var/lib/symphony/cobbler/distro_files/RHELCOMPUTENODE6_kernel --initrd=/var/lib/symphony/cobbler/distro_files/RHELCOMPUTENODE6_initrd --arch=x86_64 --ksmeta="tree=rhelcomputenode/6" --breed redhat --os-version=rhel6 --kopts="syslog=@@server@@"
    #Create Profile
    cobbler profile add --name RHELCOMPUTENODE6 --distro RHELCOMPUTENODE6 --kickstart /var/lib/cobbler/kickstarts/symphony/RHELCOMPUTENODE6_basic.ks
    ;;
  centos7.0)
    #Get distro files
    curl http://symphony-repo/pulp/repos/centos/7.0/os/images/pxeboot/initrd.img > /var/lib/symphony/cobbler/distro_files/CentOS7.0_initrd
    curl http://symphony-repo/pulp/repos/centos/7.0/os/images/pxeboot/vmlinuz > /var/lib/symphony/cobbler/distro_files/CentOS7.0_kernel
    #Create distro
    cobbler distro add --name CentOS7.0 --kernel=/var/lib/symphony/cobbler/distro_files/CentOS7.0_kernel --initrd=/var/lib/symphony/cobbler/distro_files/CentOS7.0_initrd --arch=x86_64 --ksmeta="tree=centos/7.0" --breed redhat --os-version=rhel7 --kopts="syslog=@@server@@"
    #Create Profile
    cobbler profile add --name CentOS7.0 --distro CentOS7.0 --kickstart /var/lib/cobbler/kickstarts/symphony/CentOS7.0_basic.ks
    ;;
  *)
    echo "Unknown Group" >&2
    exit 1
    ;;
esac
