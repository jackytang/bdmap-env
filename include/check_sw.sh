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
    rpm -ivh ../tools/at-*.rpm
    rpm -ivh ../tools/bc-*.rpm
    rpm -ivh ../tools/avahi-*.rpm
    rpm -ivh ../tools/cups-lib-*.rpm
    rpm -ivh ../tools/cups-client-*.rpm
    rpm -ivh ../tools/ed-*.rpm
    rpm -ivh ../tools/m4-*.rpm
    rpm -ivh ../tools/mailx-*.rpm
    rpm -ivh ../tools/patch-*.rpm
    rpm -ivh ../tools/redhat-lsb-submod-security-*.rpm
    rpm -ivh ../tools/spax-*.rpm
    rpm -ivh ../tools/time-*.rpm
    rpm -ivh ../tools/redhat-lsb-core-*.rpm
fi
