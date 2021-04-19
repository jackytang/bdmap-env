#!/bin/bash

Install_Bdmap() {
    pushd ${oneinstack_dir}/src > /dev/null
        tar xzf bdmap.tar.gz
        /bin/cp -rf bdmap ${bdmap_install_dir}

        if [ -e "${bdmap_install_dir}/bdmap" ]; then
            rm -rf bdmap
            echo -e "${CSUCCESS}Bdmap installed successfully! ${CEND}"
        else
            rm -rf ${bdmap_install_dir}/bdmap
            echo -e "${CFAILURE}Bdmap install failed, Please contact the author! ${CEND}" && lsb_release -a
            kill -9 $$
        fi
    popd > /dev/null
}