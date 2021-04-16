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
printf "
#######################################################################
#       OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+      #
#       For more information please visit https://oneinstack.com      #
#######################################################################"

# Check if user is root
[ $(id -u) != "0" ] && {
    echo "${CFAILURE}Error: You must be root to run this script${CEND}"
    exit 1
}

oneinstack_dir=$(dirname "$(readlink -f $0)")
pushd ${oneinstack_dir} >/dev/null
. ./versions.txt
. ./options.conf
. ./include/color.sh
. ./include/check_os.sh
. ./include/check_dir.sh
. ./include/download.sh
. ./include/get_char.sh

version() {
    echo "version: 2.4"
    echo "updated date: 2021-04-01"
}

Show_Help() {
    version
    echo "Usage: $0  command ...[parameters]....
  --help, -h                  Show this help message, More: https://oneinstack.com/auto
  --version, -v               Show version info

  --docker                    Install Docker
  --docker_compose            Install Docker Compose

  --ssh_port [No.]            SSH port
  --iptables                  Enable iptables
  --reboot                    Restart the server after installation
  "
}

ARG_NUM=$#
TEMP=$(getopt -o hvV --long help,version,docker,docker_compose,ssh_port:,iptables,reboot -- "$@" 2>/dev/null)
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
    --docker)
        docker_flag=y
        shift 1
        [ -e "/usr/bin/docker" ] && {
            echo "${CWARNING}docker already installed! ${CEND}"
            unset docker_flag
        }
        ;;
    --docker_compose)
        docker_compose_flag=y
        shift 1
        [ -e "/usr/local/bin/docker-compose" ] && {
            echo "${CWARNING}docker-compose already installed! ${CEND}"
            unset docker_compose_flag
        }
        ;;
    --ssh_port)
        ssh_port=$2
        shift 2
        ;;
    --iptables)
        iptables_flag=y
        shift 1
        ;;
    --reboot)
        reboot_flag=y
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

# Use default SSH port 22. If you use another SSH port on your server
if [ -e "/etc/ssh/sshd_config" ]; then
    [ -z "$(grep ^Port /etc/ssh/sshd_config)" ] && now_ssh_port=22 || now_ssh_port=$(grep ^Port /etc/ssh/sshd_config | awk '{print $2}' | head -1)

    while :; do
        echo
        [ ${ARG_NUM} == 0 ] && read -e -p "Please input SSH port(Default: ${now_ssh_port}): " ssh_port
        ssh_port=${ssh_port:-${now_ssh_port}}

        if [ ${ssh_port} -eq 22 -o ${ssh_port} -gt 1024 -a ${ssh_port} -lt 65535 ] >/dev/null 2>&1 >/dev/null 2>&1 >/dev/null 2>&1; then
            break
        else
            echo "${CWARNING}input error! Input range: 22,1025~65534${CEND}"
            exit 1
        fi
    done

    if [ -z "$(grep ^Port /etc/ssh/sshd_config)" -a "${ssh_port}" != '22' ]; then
        sed -i "s@^#Port.*@&\nPort ${ssh_port}@" /etc/ssh/sshd_config
    elif [ -n "$(grep ^Port /etc/ssh/sshd_config)" ]; then
        sed -i "s@^Port.*@Port ${ssh_port}@" /etc/ssh/sshd_config
    fi
fi

if [ ${ARG_NUM} == 0 ]; then
    # check docker
    while :; do
        echo
        read -e -p "Do you want to install docker? [y/n]: " docker_flag

        if [[ ! ${docker_flag} =~ ^[y,n]$ ]]; then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            [ "${docker_flag}" == 'y' -a -e "${docker_install_dir}/docker" ] && {
                echo "${CWARNING}docker already installed! ${CEND}"
                unset docker_flag
            }

            break
        fi
    done

    # check docker compose
    while :; do
        echo
        read -e -p "Do you want to install docker compose? [y/n]: " docker_compose_flag

        if [[ ! ${docker_compose_flag} =~ ^[y,n]$ ]]; then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            [ "${docker_compose_flag}" == 'y' -a -e "${docker_compose_install_dir}/docker-compose" ] && {
                echo "${CWARNING}docker compose already installed! ${CEND}"
                unset docker_compose_flag
            }

            break
        fi
    done
fi

if [ ! -e ~/.oneinstack ]; then
    case "${OS}" in
    "CentOS")
        . include/init_centos.sh 2>&1 | tee -a ${oneinstack_dir}/install.log
        ;;
    "Debian")
        . include/init_debian.sh 2>&1 | tee -a ${oneinstack_dir}/install.log
        ;;
    "Ubuntu")
        . include/init_ubuntu.sh 2>&1 | tee -a ${oneinstack_dir}/install.log
        ;;
    esac
fi

# docker
if [ "${docker_flag}" == 'y' ]; then
    . include/docker.sh
    Install_Docker 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# docker_compose
if [ "${docker_compose_flag}" == 'y' ]; then
    . include/docker_compose.sh
    Install_Docker_Composer 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# get web_install_dir and db_install_dir
. include/check_dir.sh

echo "####################Congratulations########################"
[ "${docker_flag}" == 'y' ] && {
    echo -e "\n$(printf "%-32s" "docker install dir:")${CMSG}${docker_install_dir}${CEND}"
}

[ "${docker_compose_flag}" == 'y' ] && {
    echo -e "\n$(printf "%-32s" "docker compose install dir:")${CMSG}${docker_compose_install_dir}${CEND}"
}

if [ ${ARG_NUM} == 0 ]; then
    while :; do
        echo
        echo "${CMSG}Please restart the server and see if the services start up fine.${CEND}"
        read -e -p "Do you want to restart OS ? [y/n]: " reboot_flag

        if [[ ! "${reboot_flag}" =~ ^[y,n]$ ]]; then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            break
        fi
    done
fi

[ "${reboot_flag}" == 'y' ] && reboot
