#!/bin/sh

# This script installs the following dependencies for SnapRoute dockerLab:
#   git and docker (using get.docker.com script)
#   it assumes presence of curl or wget along with python
#This file is used to check if the host machine has the necessary services running on it. The services required for
#the Framework are Robot Framework nd Docker. If the services are not installed, this file installs it. Just
#execute this file as any script file.

set +e
command_exists() {
    command -v "$@" > /dev/null 2>&1
}

do_install() {

    # verify this is a linux machine
    os="`uname`"
    if [ "$os" != "Linux" ]; then
        echo " The underlying Operating System is not Linux. "
        echo " Docker with flexswitch is not supported."
        exit 1
    fi

    sh_c='sh -c'
    if [ "$user" != 'root' ]; then
        if command_exists sudo; then
            sh_c='sudo -E sh -c'
        elif command_exists su; then
            sh_c='su -c'
        else
            >&2 echo "
            Error: this installer needs the ability to run commands as root.
            We are unable to find either "sudo" or "su" available to make this 
            happen.
            "
            exit 1
        fi
    fi


    update_c=''
    repo_c=''
    if command_exists apt-get; then
        update_c='apt-get -y -q update'
        repo_c='apt-get -y install'
    elif command_exists dnf; then
        update_c='dnf -y -q upgrade'
        repo_c='dnf -y install'
    elif command_exists yum; then
        update_c='yum -y -q update'
        repo_c='yum -y install'
    elif command_exists pip;then
        update_c='pip -y -q upgrade'
        repo_c='pip -y install'
         
    else
        >&2 echo "
        Unable to find a package management utility (apt, dnf, yum).
        This installer has only been tested on Debian, Centos, and Fedora.
        Please try the manual installation method:
            http://docs.snaproute.com/docker_labs/installing_docker/
        "
        exit 1
    fi

    curl=''
    if command_exists curl; then
        curl='curl -sSL'
    elif command_exists wget; then
        curl='wget -qO-'
    else
        >&2 echo "
        Unable to find curl/wget utility for docker install
        "
        exit 1
    fi

    # perform repo update
    $sh_c "$update_c"

    # install git
    echo -e "\n\n***** INSTALLING GIT *****\n\n"
    $sh_c "$repo_c git"

    # verify python is installed
    if ! command_exists python; then
        echo -e "\n\n***** INSTALLING PYTHON *****\n\n"
        $sh_c "$repo_c python"
    fi

    # verify wget is installed (required for url upgrade)
    if ! command_exists wget; then
        echo -e "\n\n***** INSTALLING wget *****\n\n"
        $sh_c "$repo_c wget"
    fi

    # install docker
    echo -e "\n\n***** INSTALLING DOCKER *****\n\n"
    $curl https://get.docker.com/ | sh

    echo -e "\n\n***** INSTALLED DOCKER SUCCESSFULLY ***** \n\n"


    # verify pip is installed
    if ! command_exists pip; then
	echo -e "\n\n***** INSTALLING pip *****\n\n"
        $sh_c "$repo_c python-pip"
    fi

    # install robot framework
    echo -e "\n\n***** INSTALLING ROBOT FRAMEWORK *****\n\n"
    pip install robotframework
    pip install --upgrade robotframework

    # install request module of python
    echo -e "\n\n***** INSTALLING REQUEST MODULE *****\n\n"
    pip install requests
    

}

do_install
