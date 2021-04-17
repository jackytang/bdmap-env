#!/bin/bash

Install_Nginx_Image() {
    pushd ${oneinstack_dir}/src > /dev/null
        if [ -f "${oneinstack_dir}/src/nginx.tar" ]; then
            docker load -i nginx.tar
            docker image ls | grep nginx
            echo -e "${CSUCCESS}Nginx Docker Image installed successfully!${CEND}"
        else
            echo -e "${CFAILURE}Nginx Docker Image install failed, Please contact the author!${CEND}" && lsb_release -a
            kill -9 $$
        fi
    popd > /dev/null
}

Install_Mysql_Image() {
    pushd ${oneinstack_dir}/src > /dev/null
        if [ -f "${oneinstack_dir}/src/mysql.tar" ]; then
            docker load -i mysql.tar
            docker image ls | grep mysql
            echo -e "${CSUCCESS}MySQL Docker Image installed successfully!${CEND}"
        else
            echo -e "${CFAILURE}MySQL Docker Image install failed, Please contact the author!${CEND}" && lsb_release -a
            kill -9 $$
        fi
    popd > /dev/null
}

Install_Redis_Image() {
    pushd ${oneinstack_dir}/src > /dev/null
        if [ -f "${oneinstack_dir}/src/redis.tar" ]; then
            docker load -i redis.tar
            docker image ls | grep redis
            echo -e "${CSUCCESS}Redis Docker Image installed successfully!${CEND}"
        else
            echo -e "${CFAILURE}Redis Docker Image install failed, Please contact the author!${CEND}" && lsb_release -a
            kill -9 $$
        fi
    popd > /dev/null
}

Install_Java_Image() {
    pushd ${oneinstack_dir}/src > /dev/null
        if [ -f "${oneinstack_dir}/src/java.tar" ]; then
            docker load -i java.tar
            docker image ls | grep java
            echo -e "${CSUCCESS}JavaSDK Docker Image installed successfully!${CEND}"
        else
            echo -e "${CFAILURE}JavaSDK Docker Image install failed, Please contact the author!${CEND}" && lsb_release -a
            kill -9 $$
        fi
    popd > /dev/null
}

Install_Java_Mysql_Image() {
    pushd ${oneinstack_dir}/src > /dev/null
        if [ -f "${oneinstack_dir}/src/java-mysql.tar" ]; then
            docker load -i java-mysql.tar
            docker image ls | grep java-mysql
            echo -e "${CSUCCESS}JavaSDK And MySQL Client Docker Image installed successfully!${CEND}"
        else
            echo -e "${CFAILURE}JavaSDK And MySQL Client Docker Image install failed, Please contact the author!${CEND}" && lsb_release -a
            kill -9 $$
        fi
    popd > /dev/null
}
