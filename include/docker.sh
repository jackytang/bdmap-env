#!/bin/bash

Install_Docker() {
    pushd ${oneinstack_dir}/src > /dev/null
        tar xzvf docker-${docker_ver}.tgz
        mkdir -p ${docker_install_dir}
        cp -rf docker/* ${docker_install_dir}

        if [ -f "${docker_install_dir}/bin/docker" ]; then
            ln -s ${docker_install_dir}/bin/* /usr/local/bin/

            if [ -e /bin/systemctl ]; then
                /bin/cp ../init.d/docker.service /lib/systemd/system/
                # chmod +x /etc/systemd/system/docker.service
                sed -i "s@/usr/local/docker@${docker_install_dir}@g" /lib/systemd/system/docker.service

                systemctl daemon-reload
                systemctl enable docker.service
            else
                # /bin/cp ../init.d/docker-init /etc/init.d/docker
                # sed -i "s@/usr/local/docker@${docker_install_dir}@g" /etc/init.d/docker
                # [ "${PM}" == 'yum' ] && { cc start-stop-daemon.c -o /sbin/start-stop-daemon; chkconfig --add redis-server; chkconfig redis-server on; }
                # [ "${PM}" == 'apt-get' ] && update-rc.d docker defaults
            fi

            systemctl start docker

            rm -rf docker-${docker_ver}.tgz
            echo "${CSUCCESS}docker installed successfully! ${CEND}"
        else
            rm -rf ${docker_install_dir}
            echo "${CFAILURE}Docker install failed, Please contact the author! ${CEND}" && lsb_release -a
            kill -9 $$
        fi
    popd > /dev/null
}

Install_Docker_Composer() {
    pushd ${oneinstack_dir}/src > /dev/null
        mkdir -p ${docker_compose_install_dir}
        /bin/cp ./docker-compose-Linux-x86_64 ${docker_compose_install_dir}

        if [ -f "${docker_compose_install_dir}/bin/docker-compose" ]; then
            chmod +x ${docker_compose_install_dir}/bin/docker-compose
            ln -s ${docker_compose_install_dir}/bin/* /usr/local/bin/
            echo "${CSUCCESS}docker compose installed successfully! ${CEND}"
        else
            echo "${CFAILURE}Docker Compose install failed, Please contact the author! ${CEND}" && lsb_release -a
            kill -9 $$
        fi
    popd > /dev/null
}

