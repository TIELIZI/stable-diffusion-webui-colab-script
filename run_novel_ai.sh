#!/bin/bash
# install pythn3.10
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get install python3.10
/usr/bin/python3.10 --version
sudo apt-get install python3.10-distutils && wget https://bootstrap.pypa.io/get-pip.py && /usr/bin/python3.10 get-pip.py
/usr/bin/python3.10 -m pip install -U pip

# Set defaults
# Install directory without trailing slash
install_dir="/content/webui"
mkdir -p $install_dir

# Name of the subdirectory (defaults to stable-diffusion-webui)
clone_dir="stable-diffusion-webui"

# python3 executable
python_cmd="/usr/bin/python3.10"

# git executable
export GIT="git"

# launch script
LAUNCH_SCRIPT="launch.py"

# Disable sentry logging
export ERROR_REPORTING=FALSE

# Do not reinstall existing pip packages on Debian/Ubuntu
export PIP_IGNORE_INSTALLED=0

# Pretty print
delimiter="################################################################"

printf "\n%s\n" "${delimiter}"
printf "\e[1m\e[32mInstall script for stable-diffusion + Web UI\n"
printf "\e[1m\e[34mTested on Debian 11 (Bullseye)\e[0m"
printf "\n%s\n" "${delimiter}"

if [ -d .git ]
then
    printf "\n%s\n" "${delimiter}"
    printf "Repo already cloned, using it as install directory"
    printf "\n%s\n" "${delimiter}"
    install_dir="${PWD}/../"
    clone_dir="${PWD##*/}"
fi

printf "\n%s\n" "${delimiter}"
printf "Clone or update stable-diffusion-webui"
printf "\n%s\n" "${delimiter}"
cd "${install_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/, aborting...\e[0m" "${install_dir}"; exit 1; }
if [ -d "${clone_dir}" ]
then
    cd "${clone_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/%s/, aborting...\e[0m" "${install_dir}" "${clone_dir}"; exit 1; }
    "${GIT}" pull
else
    "${GIT}" clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "${clone_dir}"
    cd "${clone_dir}"/ || { printf "\e[1m\e[31mERROR: Can't cd to %s/%s/, aborting...\e[0m" "${install_dir}" "${clone_dir}"; exit 1; }
fi

# download moel
# filename="model.zip"
# curl -Lb ./cookie "https://www.dropbox.com/s/kf6cp7g97ooe1jf/models.zip?dl=0" -o ${filename}
# unzip -o model.zip -d /content/webui/stable-diffusion-webui/
if [ -d "/content/drive/MyDrive/models/" ]
then
    mkdir -p /content/webui/stable-diffusion-webui/models/Stable-diffusion/
    mkdir -p /content/webui/stable-diffusion-webui/models/hypernetworks/
    cp -f /content/drive/MyDrive/models/Stable-diffusion/* /content/webui/stable-diffusion-webui/models/Stable-diffusion/
    cp -f /content/drive/MyDrive/models/hypernetworks/* /content/webui/stable-diffusion-webui/models/hypernetworks/
fi

printf "\n%s\n" "${delimiter}"
printf "Launching launch.py..."
printf "\n%s\n" "${delimiter}"
"${python_cmd}" "${LAUNCH_SCRIPT}"  --share
