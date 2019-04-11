#!/usr/bin/env bash

# Instructions: https://index.ros.org/doc/ros2/Installation/Linux-Install-Debians/
set -e

# flags
INSTALL_OPTIONAL=1
USE_ROS1_PKGS=1  # additional packages for examples
INSTALL_BASHRC_LINE=1
INSTALL_ADDITIONAL_TOOLS=1  # for colcon etc.

function print_sec {
    printf "\n===============================================\n"
    printf "$1...\n"
    printf "===============================================\n\n"
}

# Determine ROS version to install
ROS_DISTRO="crystal"  # default
if [[ $# == "1" ]]
then
    ROS_DISTRO="$1"
    if [[ "${ROS_DISTRO}" != "crystal" && "${ROS_DISTRO}" != "bouncy" && "${ROS_DISTRO}" != "ardent" ]]
    then
        echo "[W] Unknown ROS distro provided [${ROS_DISTRO}]. Proceed cautiously...  <ENTER>"
        read
    fi
elif [[ $# != "0" && $# != "1" ]]
then
    echo "Usage: "${BASH_SOURCE[0]}" [ROS-DISTRO-NAME]"
    exit 1
fi
export ROS_DISTRO

print_sec "Checking system requirements"
printf "\tlocale...\n"
if [[ $LANG != *UTF-8 ]]
then
    echo "Set locale to a UTF-8 compatible one and try again."
    exit 1
fi

printf "\tlinux version...\n"
if [[ $( cat /etc/*-release | grep -e "^NAME" | cut -d= -f2 ) != "\"Ubuntu\"" ]]
then
    echo "[W] Instructions are only tested on Ubuntu. Proceed cautiously...  <ENTER>"
    read
elif [[ ( $(cat /etc/*-release | grep -e "^DISTRIB_RELEASE" | cut -d= -f2 ) != "18.04" && $(cat /etc/*-release | grep -e "^DISTRIB_RELEASE" | cut -d= -f2) != "16.04" )  ]]
then
    echo "[W] Instructions are only tested on 18.04 / 16.04 versions of Ubuntu. Proceed cautiously...  <ENTER>"
    read
fi


print_sec "Installing bulk of packages"
sudo apt update && sudo apt install curl gnupg2 lsb-release
curl http://repo.ros2.org/repos.key | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'
sudo apt update
sudo apt install ros-${ROS_DISTRO}-desktop
# sudo apt install ros-$ROS_DISTRO-ros-base

if [[ "$INSTALL_OPTIONAL" == "1" ]]
then
    sudo apt install python3-pip
    pip3 install --user argcomplete
fi

if [[ "$INSTALL_BASHRC_LINE" == "1" ]]
then
    print_sec "Adding rule to bashrc"
    source /opt/ros/${ROS_DISTRO}/setup.bash
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
fi

if [[ "${ROS_DISTRO}" == "bouncy" ]]
then
    print_sec "Installing additional RMW implementations"
    sudo apt install ros-${ROS_DISTRO}-rmw-opensplice-cpp # for OpenSplice
    sudo apt install ros-${ROS_DISTRO}-rmw-connext-cpp # for RTI Connext (requires license agreement)
fi

if [[ $USE_ROS1_PKGS == "1" ]]
then
    print_sec "Installing ROS1 bridge"
    sudo apt install ros-${ROS_DISTRO}-ros1-bridge
fi

if [[ $USE_ROS1_PKGS == "1" ]]
then
    if [[ "${ROS_DISTRO}" != "crystal" ]]
    then
        print_sec "Installing turtlebot example2 packages"
        sudo apt install ros-${ROS_DISTRO}-turtlebot2-*
    else
        printf "[W] turtlebot2 packages not available for crystal yet...\n"
    fi
fi

if [[ $INSTALL_ADDITIONAL_TOOLS == "1" ]]
then
    print_sec "Installing additional tools"
    sudo apt install python3-colcon-common-extensions
fi


print_sec "All done."
