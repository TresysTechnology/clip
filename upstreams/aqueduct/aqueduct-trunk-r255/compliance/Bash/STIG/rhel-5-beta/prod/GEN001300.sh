#Aqueduct - Compliance Remediation Content
#Copyright (C) 2011,2012  Vincent C. Passaro (vincent.passaro@gmail.com)
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor,
#Boston, MA  02110-1301, USA.

#!/bin/bash
######################################################################
#By Tummy a.k.a Vincent C. Passaro				     #
#Vincent[.]Passaro[@]gmail[.]com	         		     #
#www.vincentpassaro.com						     #
######################################################################
#_____________________________________________________________________
#|  Version |   Change Information  |      Author        |    Date    |
#|__________|_______________________|____________________|____________|
#|    1.0   |   Initial Script      | Vincent C. Passaro | 20-oct-2011|
#|	    |   Creation	    |                    |            |
#|__________|_______________________|____________________|____________|
#
#
#  - Updated by Shannon Mitchell(shannon.mitchell@fusiontechnology-llc.com)
# on 09-jan-2012 from an exact find perm match to one that finds all the 
# ones with just the unwanted bits. Also added wildcard after so and a to 
# match version suffixs and added support for lib64 dirs.
								     

#######################DISA INFORMATION###############################
#Group ID (Vulid): V-793
#Group Title: Library File Permissions
#Rule ID: SV-793r7_rule
#Severity: CAT II
#Rule Version (STIG-ID): GEN001300
#Rule Title: Library files must have mode 0755 or less permissive.
#
#Vulnerability Discussion: Unauthorized access could destroy the 
#integrity of the library files.
#
#Responsibility: System Administrator
#IAControls: DCSL-1
#
#Check Content: 
#Check the mode of library files.
#
#Procedure:
# ls -lLR /usr/lib /lib
#
#If any of the library files have a mode more permissive than 0755, 
#this is a finding.
#
#Fix Text: Change the mode of library files to 0755 or less permissive.
#
#Procedure (example):
# chmod 0755 /path/to/library-file
#
#Note: Library files should have an extension of ".a" or a ".so" extension, 
#possibly followed by a version number.    
#######################DISA INFORMATION###############################

#Global Variables#
PDI=GEN001300

#Start-Lockdown
for LIBDIR in /usr/lib /usr/lib64 /lib /lib64
do
  if [ -d $LIBDIR ]
  then
    for BADLIBFILE in `find $LIBDIR -type f -perm /7022 \( -name *.so* -o -name *.a* \)`
    do
      chmod o-s,g-ws,o-wt $BADLIBFILE
    done
  fi
done

