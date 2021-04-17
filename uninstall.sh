#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
echo -e "#######################################################################"
echo -e "#       OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+      #"
echo -e "#                         Uninstall OneinStack                        #"
echo -e "#       For more information please visit https://oneinstack.com      #"
echo -e "#######################################################################"

# Check if user is root
[ $(id -u) != "0" ] && {
    echo "${CFAILURE}Error: You must be root to run this script${CEND}"
    exit 1
}

oneinstack_dir=$(dirname "$(readlink -f $0)")
pushd ${oneinstack_dir} >/dev/null
. ./options.conf
. ./include/color.sh
. ./include/get_char.sh
. ./include/check_dir.sh

version() {
    echo "version: 2.4"
    echo "updated date: 2021-04-01"
}

Show_Help() {
    echo
    echo "Usage: $0  command ...[parameters]...."
    echo "--version, -v                 Show version info"
    echo "--quiet, -q                   quiet operation"
    echo "--all                         Uninstall All"
    echo "--docker                      Uninstall Docker"
    echo "--docker_compose              Uninstall Docker Compose"
}

ARG_NUM=$#
TEMP=$(getopt -o hvVq --long help,version,quiet,all,docker,docker_compose -- "$@" 2>/dev/null)
[ $? != 0 ] && echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
eval set -- "${TEMP}"
while :; do
    [ -z "$1" ] && break
    case "$1" in
    -h | --help)
        Show_Help
        exit 0
        ;;
    -v | -V | --version)
        version
        exit 0
        ;;
    -q|--quiet)
        quiet_flag=y
        uninstall_flag=y
        shift 1
        ;;
    --all)
        all_flag=y
        docker_flag=y
        docker_compose_flag=y
        shift 1
        ;;
    --docker)
        docker_flag=y
        shift 1
        ;;
    --docker_compose)
        docker_compose_flag=y
        shift 1
        ;;
    --)
        shift
        ;;
    *)
        echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
        ;;
    esac
done

Uninstall_Status() {
    if [ "${quiet_flag}" != 'y' ]; then
        while :; do
            echo
            read -e -p "Do you want to uninstall? [y/n]: " uninstall_flag
            if [[ ! ${uninstall_flag} =~ ^[y,n]$ ]]; then
                echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
            else
                break
            fi
        done
    fi
}

Print_Warn() {
    echo
    echo "${CWARNING}You will uninstall OneinStack, Please backup your configure files! ${CEND}"
}

Print_Docker() {
    [ -e "${docker_install_dir}" ] && echo "${CMSG}${docker_install_dir}${CEND}"
    [ -e "/etc/init.d/docker" ] && echo "${CMSG}/etc/init.d/docker${CEND}"
    [ -e "/lib/systemd/system/docker.service" ] && echo "${CMSG}/lib/systemd/system/docker.service${CEND}"
}

Uninstall_Docker() {
    [ -e "${docker_install_dir}" ] && {
        service docker stop >/dev/null 2>&1
        rm -rf ${docker_install_dir} /etc/init.d/docker
        rm -rf /usr/local/bin/docker* /usr/local/bin/containerd* /usr/local/bin/ctr /usr/local/bin/runc
        echo "${CMSG}Docker uninstall completed! ${CEND}"
    }

    [ -e "/lib/systemd/system/docker.service" ] && {
        systemctl disable docker >/dev/null 2>&1
        rm -rf /lib/systemd/system/docker.service
    }
}

Print_Docker_Compose() {
    [ -e "${docker_compose_install_dir}" ] && echo "${CMSG}${docker_compose_install_dir}${CEND}"
    [ -e "/usr/bin/docker-compose" ] && echo "${CMSG}/usr/bin/docker-compose${CEND}"
}

Uninstall_Docker_Compose() {
    [ -e "${docker_compose_install_dir}" ] && {
        rm -rf ${docker_compose_install_dir} /usr/bin/docker-compose
        echo "${CMSG}Docker Compose uninstall completed! ${CEND}"
    }
}

Menu() {
    while :; do
        echo 'What Are You Doing?'
        echo -e "\t${CMSG} 0${CEND}. Uninstall All"
        echo -e "\t${CMSG} 1${CEND}. Uninstall Docker"
        echo -e "\t${CMSG} 2${CEND}. Uninstall Docker Compose"
        echo -e "\t${CMSG} q${CEND}. Exit"
        echo

        read -e -p "Please input the correct option: " Number
        if [[ ! "${Number}" =~ ^[0-2,q]$ ]]; then
            echo "${CWARNING}input error! Please only input 0~2 and q${CEND}"
        else
            case "$Number" in
            0)
                Print_Warn
                Print_Docker
                Print_Docker_Compose
                Uninstall_Status
                if [ "${uninstall_flag}" == 'y' ]; then
                    Uninstall_Docker
                    Uninstall_Docker_Compose
                else
                    exit
                fi
                ;;
            1)
                Print_Docker
                Uninstall_Status
                [ "${uninstall_flag}" == 'y' ] && Uninstall_Docker || exit
                ;;
            2)
                Print_Docker_Compose
                Uninstall_Status
                [ "${uninstall_flag}" == 'y' ] && Uninstall_Docker_Compose || exit
                ;;
            q)
                exit
                ;;
            esac
        fi
    done
}

if [ ${ARG_NUM} == 0 ]; then
    Menu
else
    [ "${docker_flag}" == 'y' ] && Print_Docker
    [ "${docker_compose_flag}" == 'y' ] && Print_Docker_Compose

    Uninstall_Status
    if [ "${uninstall_flag}" == 'y' ]; then
        [ "${docker_flag}" == 'y' ] && Uninstall_Docker
        [ "${docker_compose_flag}" == 'y' ] && Uninstall_Docker_Compose
    fi
fi
