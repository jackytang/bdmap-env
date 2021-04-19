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
. ./versions.txt
. ./options.conf
. ./include/menu.sh
. ./include/color.sh
. ./include/check_os.sh
. ./include/check_dir.sh
. ./include/download.sh
. ./include/get_char.sh

Version() {
    echo -e "version: 2.4"
    echo -e "updated date: 2021-04-01 "
}

Show_Help() {
    echo -e "Usage: $0  command ...[parameters]...."
    echo -e "--help, -h                     Show this help message"
    echo -e "--version, -v                  Show version info"
    echo -e "--docker                       Install Docker"
    echo -e "--docker_compose               Install Docker Compose"
    echo -e "--docker_image_option [0-5]    Install Docker Image"
    echo -e "--ssh_port [No.]               SSH port"
    echo -e "--reboot                       Restart the server after installation"
}

ARG_NUM=$#
TEMP=$(getopt -o hvV --long help,version,docker,docker_compose,docker_image_option:,ssh_port:,reboot -- "$@" 2>/dev/null)
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
        [ -e "${docker_install_dir}/docker" ] && {
            echo -e "${CWARNING}docker already installed! ${CEND}"
            unset docker_flag
        }
        ;;
    --docker_compose)
        docker_compose_flag=y
        shift 1
        [ -e "${docker_compose_install_dir}/docker-compose" ] && {
            echo -e "${CWARNING}docker compose already installed!${CEND}"
            unset docker_compose_flag
        }
        ;;
    --docker_image_option)
        docker_image_option=$2; shift 2
        [[ ! ${docker_image_option} =~ ^[0-5]$ ]] && {
            echo -e "${CWARNING}docker_image_option input error! Please only input number 0~5${CEND}"
            exit 1
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
        echo -e "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
        ;;
    esac
done

# Use default SSH port 22. If you use another SSH port on your server
if [ -e "/etc/ssh/sshd_config" ]; then
    [ -z "$(grep ^Port /etc/ssh/sshd_config)" ] && {
        now_ssh_port=22 || now_ssh_port=$(grep ^Port /etc/ssh/sshd_config | awk '{print $2}' | head -1)
    }

    while :; do
        [ ${ARG_NUM} == 0 ] && {
            read -e -p "Please input SSH port(Default: ${now_ssh_port}): " ssh_port
        }

        ssh_port=${ssh_port:-${now_ssh_port}}
        if [ ${ssh_port} -eq 22 -o ${ssh_port} -gt 1024 -a ${ssh_port} -lt 65535 ] >/dev/null 2>&1 >/dev/null 2>&1 >/dev/null 2>&1; then
            break
        else
            echo -e "${CWARNING}input error! Input range: 22,1025~65534 \n${CEND}"
            exit 1
        fi
    done

    if [ -z "$(grep ^Port /etc/ssh/sshd_config)" -a "${ssh_port}" != '22' ]; then
        sed -i "s@^#Port.*@&Port ${ssh_port}@" /etc/ssh/sshd_config
    elif [ -n "$(grep ^Port /etc/ssh/sshd_config)" ]; then
        sed -i "s@^Port.*@Port ${ssh_port}@" /etc/ssh/sshd_config
    fi
fi

if [ ${ARG_NUM} == 0 ]; then
    # check docker
    while :; do
        read -e -p "Do you want to install docker? [y/n]: " docker_flag

        if [[ ! ${docker_flag} =~ ^[y,n]$ ]]; then
            echo -e "${CWARNING}input error! Please only input 'y' or 'n' ${CEND}"
        else
            [ -e "${docker_install_dir}/docker" ] && {
                echo -e "${CWARNING}docker already installed! ${CEND}"
                unset docker_flag
            }

            break
        fi
    done

    # check docker compose
    while :; do
        read -e -p "Do you want to install docker compose? [y/n]: " docker_compose_flag

        if [[ ! ${docker_compose_flag} =~ ^[y,n]$ ]]; then
            echo -e "${CWARNING}input error! Please only input 'y' or 'n' ${CEND}"
        else
            [ "${docker_compose_flag}" == 'y' -a -e "${docker_compose_install_dir}/docker-compose" ] && {
                echo -e "${CWARNING}docker compose already installed! ${CEND}"
                unset docker_compose_flag
            }

            break
        fi
    done
fi

# docker
if [ "${docker_flag}" == 'y' ]; then
    . include/docker.sh
    Install_Docker 2>&1 | tee -a ${oneinstack_dir}/install.log
    Create_Network 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# docker compose
if [ "${docker_compose_flag}" == 'y' ]; then
    . include/docker_compose.sh
    Install_Docker_Composer 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# choice docker image
if [ ${ARG_NUM} == 0 ]; then
    while :; do
        read -e -p "Do you want to install docker image? [y/n]: " docker_image_flag

        if [[ ! ${docker_image_flag} =~ ^[y,n]$ ]]; then
            echo -e "${CWARNING}input error! Please only input 'y' or 'n' ${CEND}"
        else
            if [ "${docker_image_flag}" == 'y' ]; then
                [ ! -e "${docker_install_dir}/docker" ] && {
                    echo  -e "${CWARNING}Docker is not install! ${CEND}"
                    unset docker_image_option
                    break
                }

                # Menu
                while :; do
                    echo 'Please select a docker image version:'
                    echo -e "\t${CMSG} 0${CEND}. Install all image"
                    echo -e "\t${CMSG} 1${CEND}. Install nginx image"
                    echo -e "\t${CMSG} 2${CEND}. Install mysql image"
                    echo -e "\t${CMSG} 3${CEND}. Install redis image"
                    echo -e "\t${CMSG} 4${CEND}. Install java sdk image"
                    echo -e "\t${CMSG} 5${CEND}. Install java sdk + mysql client image"
                    echo -e "\t${CMSG} q${CEND}. Exit"

                    read -e -p "Please input the correct option: " docker_image_option
                    if [[ ! "${docker_image_option}" =~ ^[0-5,q]$ ]]; then
                        echo -e "${CWARNING}input error! Please only input 0~5 and q${CEND}"
                    else
                        . include/docker_image.sh

                        case "$docker_image_option" in
                            0)
                                Install_Nginx_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
                                Install_Mysql_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
                                Install_Redis_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
                                Install_Java_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
                                Install_Java_Mysql_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
                                ;;
                            1)
                                # echo -e "\t${CMSG} 2${CEND}. Install nginx"
                                Install_Nginx_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
                                ;;
                            2)
                                # echo -e "\t${CMSG} 3${CEND}. Install mysql"
                                Install_Mysql_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
                                ;;
                            3)
                                # echo -e "\t${CMSG} 4${CEND}. Install redis"
                                Install_Redis_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
                                ;;
                            4)
                                # echo -e "\t${CMSG} 5${CEND}. Install java sdk"
                                Install_Java_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
                                ;;
                            5)
                                Install_Java_Mysql_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
                                ;;
                            q)
                                break
                                ;;
                        esac
                    fi
                done
            fi

            break
        fi
    done
fi

# choice docker image
if [ ${ARG_NUM} > 1 ]; then
    . include/docker_image.sh

    case "$docker_image_option" in
        0)
            Install_Nginx_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
            Install_Mysql_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
            Install_Redis_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
            Install_Java_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
            Install_Java_Mysql_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
            ;;
        1)
            Install_Nginx_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
            ;;
        2)
            Install_Mysql_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
            ;;
        3)
            Install_Redis_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
            ;;
        4)
            Install_Java_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
            ;;
        5)
            Install_Java_Mysql_Image 2>&1 | tee -a ${oneinstack_dir}/install.log
            ;;
        q)
            ;;
    esac
fi

. include/bdmap.sh
Install_Bdmap

if [ ! -e ~/.oneinstack ]; then
    case "${OS}" in
    "CentOS")
        . include/init_dentos.sh > ${oneinstack_dir}/install.log
        ;;
    "Debian")
        . include/init_debian.sh > ${oneinstack_dir}/install.log
        ;;
    "Ubuntu")
        . include/init_ubuntu.sh > ${oneinstack_dir}/install.log
        ;;
    esac
fi

echo "############################Congratulations############################"
[ "${docker_flag}" == 'y' ] && {
    echo -e "$(printf "%-32s" "docker install dir:")${CMSG}${docker_install_dir}${CEND}"
}

[ "${docker_compose_flag}" == 'y' ] && {
    echo -e "$(printf "%-32s" "docker compose install dir:")${CMSG}${docker_compose_install_dir}${CEND}"
}

[[ "${docker_image_option}" =~ ^[0-5,q]$ ]] && {
    docker image ls
}

if [ ${ARG_NUM} == 0 ]; then
    while :; do
        echo -e "${CMSG}Please restart the server and see if the services start up fine.${CEND}"
        read -e -p "Do you want to restart OS ? [y/n]: " reboot_flag

        if [[ ! "${reboot_flag}" =~ ^[y,n]$ ]]; then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            break
        fi
    done
fi

[ "${reboot_flag}" == 'y' ] && reboot
