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

AVAILABLE_GROUPS="centos6 centos7 rhel6 rhelcomputenode6"

GROUP=$1

if [ -z $GROUP ]; then
  echo "Please specify group, Available Groups: [$AVAILABLE_GROUPS]" >&2
  exit 1
fi

REPOBASE=$2
[ -z "$REPOBASE" ] && REPOBASE=alces

case $GROUP in
  centos6)
    case $REPOBASE in
      local)
        BASEURL="http://symphony-repo/pulp/repos/centos/6/os/images/pxeboot/"
        INSTALLURL="http://symphony-repo/pulp/repos/centos/6/os/"
        ;;
      alces)
        BASEURL="http://repo.alces-software.com/pulp/repos/centos/6/os/images/pxeboot/"
        INSTALLURL="http://repo.alces-software.com/pulp/repos/centos/6/os/"
        ;;
      *)
        BASEURL="http://www.mirrorservice.org/sites/mirror.centos.org/6/os/x86_64/images/pxeboot/"
        INSTALLURL="http://www.mirrorservice.org/sites/mirror.centos.org/6/os/x86_64/"
        ;;
    esac
    #Get distro files
    curl $BASEURL/initrd.img > /var/lib/symphony/cobbler/distro_files/CentOS6_initrd
    curl $BASEURL/vmlinuz > /var/lib/symphony/cobbler/distro_files/CentOS6_kernel
    #Create distro
    cobbler distro add --name CentOS6 --kernel=/var/lib/symphony/cobbler/distro_files/CentOS6_kernel --initrd=/var/lib/symphony/cobbler/distro_files/CentOS6_initrd --arch=x86_64 --ksmeta="tree=centos/6 url=$INSTALLURL" --breed redhat --os-version=rhel6 --kopts="syslog=@@server@@" --clobber
    #Create Profile
    cobbler profile add --name CentOS6 --distro CentOS6 --kickstart /var/lib/cobbler/kickstarts/symphony/CentOS6_basic.ks --clobber
    ;;
  sl6)
    case $REPOBASE in
      local)
        BASEURL="http://symphony-repo/pulp/repos/sl/6/os/images/pxeboot/"
        INSTALLURL="http://symphony-repo/pulp/repos/sl/6/os/"
        ;;
      alces)
        BASEURL="http://repo.alces-software.com/pulp/repos/sl/6/os/images/pxeboot/"
        INSTALLURL="http://repo.alces-software.com/pulp/repos/sl/6/os/"
        ;;
      *)
        BASEURL="http://anorien.csc.warwick.ac.uk/mirrors/scientific/6x/x86_64/os/images/pxeboot/"
        INSTALLURL="http://anorien.csc.warwick.ac.uk/mirrors/scientific/6x/x86_64/os/"
        ;;
    esac
    #Get distro files  
    curl $BASEURL/initrd.img > /var/lib/symphony/cobbler/distro_files/SL6_initrd
    curl $BASEURL/vmlinuz > /var/lib/symphony/cobbler/distro_files/SL6_kernel
    #Create distro
    cobbler distro add --name SL6 --kernel=/var/lib/symphony/cobbler/distro_files/SL6_kernel --initrd=/var/lib/symphony/cobbler/distro_files/SL6_initrd --arch=x86_64 --ksmeta="tree=sl/6 url=$INSTALLURL" --breed redhat --os-version=rhel6 --kopts="syslog=@@server@@" --clobber
    #Create Profile
    cobbler profile add --name SL6 --distro SL6 --kickstart /var/lib/cobbler/kickstarts/symphony/SL6_basic.ks --clobber
    ;;
  rhel6)
    #Get distro files
    case $REPOBASE in
      local)
        BASEURL="http://symphony-repo/static/rhel/6/boot/images/pxeboot/"
        INSTALLURL="http://symphony-repo/static/rhel/6/boot/images/pxeboot/"
        ;;
      *)
        #Alces
        BASEURL="http://repo.alces-software.com/static/rhel/6/boot/images/pxeboot/"
        INSTALLURL="http://repo.alces-software.com/static/rhel/6/boot/"
        ;;
    esac
    curl $BASEURL/initrd.img > /var/lib/symphony/cobbler/distro_files/RHEL6_initrd
    curl $BASEURL/vmlinuz > /var/lib/symphony/cobbler/distro_files/RHEL6_kernel
    #Create distro
    cobbler distro add --name RHEL6 --kernel=/var/lib/symphony/cobbler/distro_files/RHEL6_kernel --initrd=/var/lib/symphony/cobbler/distro_files/RHEL6_initrd --arch=x86_64 --ksmeta="tree=rhel/6 url=$INSTALL_URL" --breed redhat --os-version=rhel6 --kopts="syslog=@@server@@" --clobber
    #Create Profile
    cobbler profile add --name RHEL6 --distro RHEL6 --kickstart /var/lib/cobbler/kickstarts/symphony/RHEL6_basic.ks --clobber
    ;;
  rhelcomputenode6)
    #Get distro files
    case $REPOBASE in
      local)
        BASEURL="http://symphony-repo/static/rhelcomputenode/6/boot/images/pxeboot/"
        INSTALLURL="http://symphony-repo/static/rhelcomputenode/6/boot/"
        ;;
      *)
        #Alces
        BASEURL="http://repo.alces-software.com/static/rhelcomputenode/6/boot/images/pxeboot/"
        INSTALLURL="http://repo.alces-software.com/static/rhelcomputenode/6/boot/"
        ;;
    esac
    curl $BASEURL/initrd.img > /var/lib/symphony/cobbler/distro_files/RHELCOMPUTENODE6_initrd
    curl $BASEURL/vmlinuz > /var/lib/symphony/cobbler/distro_files/RHELCOMPUTENODE6_kernel
    #Create distro
    cobbler distro add --name RHELCOMPUTENODE6 --kernel=/var/lib/symphony/cobbler/distro_files/RHELCOMPUTENODE6_kernel --initrd=/var/lib/symphony/cobbler/distro_files/RHELCOMPUTENODE6_initrd --arch=x86_64 --ksmeta="tree=rhelcomputenode/6 url=$INSTALL_URL" --breed redhat --os-version=rhel6 --kopts="syslog=@@server@@" --clobber
    #Create Profile
    cobbler profile add --name RHELCOMPUTENODE6 --distro RHELCOMPUTENODE6 --kickstart /var/lib/cobbler/kickstarts/symphony/RHELCOMPUTENODE6_basic.ks --clobber
    ;;
  centos7)
    case $REPOBASE in
      local)
        BASEURL="http://symphony-repo/pulp/repos/centos/7/os/images/pxeboot/"
        INSTALLURL="http://symphony-repo/pulp/repos/centos/7/os/"
        ;;
      alces)
        BASEURL="http://repo.alces-software.com/pulp/repos/centos/7/os/images/pxeboot/"
        INSTALLURL="http://repo.alces-software.com/pulp/repos/centos/7/os/"
        ;;
      *)
        BASEURL="http://www.mirrorservice.org/sites/mirror.centos.org/7/os/x86_64/images/pxeboot/"
        INSTALLURL="http://www.mirrorservice.org/sites/mirror.centos.org/7/os/x86_64/"
        ;;
    esac
    #Get distro files
    curl $BASEURL/initrd.img > /var/lib/symphony/cobbler/distro_files/CentOS7_initrd
    curl $BASEURL/vmlinuz > /var/lib/symphony/cobbler/distro_files/CentOS7_kernel
    #Create distro
    cobbler distro add --name CentOS7 --kernel=/var/lib/symphony/cobbler/distro_files/CentOS7_kernel --initrd=/var/lib/symphony/cobbler/distro_files/CentOS7_initrd --arch=x86_64 --ksmeta="tree=centos/7 url=$INSTALLURL" --breed redhat --os-version=rhel7 --kopts="syslog=@@server@@" --clobber
    #Create Profile
    cobbler profile add --name CentOS7 --distro CentOS7 --kickstart /var/lib/cobbler/kickstarts/symphony/CentOS7_basic.ks --clobber
    ;;
  sl7)
    case $REPOBASE in
      local)
        BASEURL="http://symphony-repo/pulp/repos/sl/7/os/images/pxeboot/"
        INSTALLURL="http://symphony-repo/pulp/repos/sl/7/os/"
        ;;
      alces)
        BASEURL="http://repo.alces-software.com/pulp/repos/sl/7/os/images/pxeboot/"
        INSTALLURL="http://repo.alces-software.com/pulp/repos/sl/7/os/"
        ;;
      *)
        BASEURL="http://anorien.csc.warwick.ac.uk/mirrors/scientific/7x/x86_64/os/images/pxeboot"
        INSTALLURL="http://anorien.csc.warwick.ac.uk/mirrors/scientific/7x/x86_64/os/"
        ;;
    esac
    #Get distro files
    curl $BASEURL/initrd.img > /var/lib/symphony/cobbler/distro_files/SL7_initrd
    curl $BASEURL/vmlinuz > /var/lib/symphony/cobbler/distro_files/SL7_kernel
    #Create distro 
    cobbler distro add --name SL7 --kernel=/var/lib/symphony/cobbler/distro_files/SL7_kernel --initrd=/var/lib/symphony/cobbler/distro_files/SL7_initrd --arch=x86_64 --ksmeta="tree=sl/7 url=$INSTALLURL" --breed redhat --os-version=rhel7 --kopts="syslog=@@server@@" --clobber
    #Create Profile 
    cobbler profile add --name SL7 --distro SL7 --kickstart /var/lib/cobbler/kickstarts/symphony/SL7_basic.ks --clobber
    ;;
  *)
    echo "Unknown Group" >&2
    exit 1
    ;;
esac
