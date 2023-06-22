#!/bin/bash
DEPS=(libgala-dev libgee-0.8-dev libglib2.0-dev libgranite-dev libgtk-3-dev meson libmutter-10-dev valac)
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

pre_install () {
    echo -e "\e[0;33m > Updating packages. \e[m"
    sudo apt update
    echo -e "\e[0;32m > Done. \e[m"
}

check_and_install () {
    echo -e "\e[0;33m > Searching for depedencies. \e[m"
    for dep in ${DEPS[@]}
    do
        if dpkg -s $dep | grep -q Status; then
            echo -e "\e[0;94m Depedency '$dep' found. \e[m"
        else
            echo -e "\e[0;31m Depedency '$dep' is not installed. Running apt install... \e[m"
            sudo apt install $dep -y
        fi
    done
    echo -e "\e[0;32m > Done. \e[m"
}

configure_build_env () {
    echo -e "\e[0;33m > Running build env configurator. \e[m"
    sudo meson build --prefix=/usr
    echo -e "\e[0;32m > Done. \e[m"
}

create_helpers () {
    rm build.sh install.sh
    echo -e "\e[0;33m > Creating build and install scripts. \e[m"
    echo -e '#!/bin/bash\nif [[ $UID != 0 ]]; then\n    echo "Please run this script with sudo:"\n    echo "sudo $0 $*"\n    exit 1\nfi\n\necho -e "\e[0;33m > Building... \e[m"\ncd build\nninja\necho -e "\e[0;32m > Done. \e[m"' >> build.sh
    sudo chmod +x ./build.sh
    echo -e "\e[0;94m Build script created. \e[m"
    echo -e '#!/bin/bash\nif [[ $UID != 0 ]]; then\n    echo "Please run this script with sudo:"\n    echo "sudo $0 $*"\n    exit 1\nfi\n\necho -e "\e[0;33m > Installing... \e[m"\ncd build\nsudo ninja install\necho -e "\e[0;32m > Done. \e[m"' >> install.sh
    sudo chmod +x ./build.sh
    echo -e "\e[0;94m Install script created. \e[m"
    echo -e "\e[0;32m > Done. \e[m"
}

post_install () {
    echo -e "\e[0;92m Now you can use ./build.sh and ./install.sh scripts to build and install application."
}

pre_install
check_and_install
configure_build_env
create_helpers
post_install
