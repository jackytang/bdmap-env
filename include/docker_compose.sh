#!/bin/bash

Install_Docker_Composer() {
    pushd ${oneinstack_dir}/src > /dev/null
        if [ -e "${docker_install_dir}" ]; then
            mkdir -p ${docker_compose_install_dir}
            /bin/cp docker-compose-Linux-x86_64 ${docker_compose_install_dir}/docker-compose

            if [ -f "${docker_compose_install_dir}/docker-compose" ]; then
                chmod +x ${docker_compose_install_dir}/docker-compose
                ln -s ${docker_compose_install_dir}/* /usr/local/bin/
                echo -e "${CSUCCESS}Docker Compose installed successfully! ${CEND}"
                echo -e ""
            else
                echo "${CFAILURE}Docker Compose install failed, Please contact the author! ${CEND}" && lsb_release -a
                echo -e ""
                kill -9 $$
            fi
        else
            echo -e "${CWARNING}Please install Docker first! ${CEND}"
            echo -e ""
        fi
    popd > /dev/null
}
