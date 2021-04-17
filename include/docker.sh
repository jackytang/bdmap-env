#!/bin/bash

Install_Docker() {
    pushd ${oneinstack_dir}/src > /dev/null
        tar xzvf docker-${docker_ver}.tgz
        mkdir -p ${docker_install_dir}
        /bin/cp -rf docker/* ${docker_install_dir}

        if [ -f "${docker_install_dir}/docker" ]; then
            ln -s ${docker_install_dir}/* /usr/local/bin/

            if [ -e /bin/systemctl ]; then
                /bin/cp ../init.d/docker.service /lib/systemd/system/
                sed -i "s@/usr/local/docker@${docker_install_dir}@g" /lib/systemd/system/docker.service

                systemctl daemon-reload
                systemctl enable docker.service
                systemctl start docker
            fi

            rm -rf docker/
            echo -e "${CSUCCESS}Docker installed successfully! ${CEND}"
            echo -e ""
        else
            rm -rf ${docker_install_dir}
            echo -e "${CFAILURE}Docker install failed, Please contact the author! ${CEND}" && lsb_release -a
            echo -e ""
            kill -9 $$
        fi
    popd > /dev/null
}

Create_Network() {
    docker network rm database
    docker network create database

    echo -e "${CSUCCESS}Docker create network database successfully! ${CEND}"
    echo -e ""
}
