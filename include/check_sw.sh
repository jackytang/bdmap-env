#!/bin/bash
# Author:  Alpha Eva <kaneawk AT gmail.com>
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

# Install centOS dependency
if [ -e "/usr/bin/yum" ]; then
    pushd ${oneinstack_dir}/tools > /dev/null
        rpm -ivh ./at-*.rpm
        rpm -ivh ./bc-*.rpm
        rpm -ivh ./avahi-*.rpm
        rpm -ivh ./cups-libs-*.rpm
        rpm -ivh ./cups-client-*.rpm
        rpm -ivh ./ed-*.rpm
        rpm -ivh ./m4-*.rpm
        rpm -ivh ./mailx-*.rpm
        rpm -ivh ./patch-*.rpm
        rpm -ivh ./psmisc-*.rpm
        rpm -ivh ./redhat-lsb-submod-security-*.rpm
        rpm -ivh ./spax-*.rpm
        rpm -ivh ./time-*.rpm
        rpm -ivh ./redhat-lsb-core-*.rpm
    popd > /dev/null
fi
