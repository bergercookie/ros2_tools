#!/usr/bin/env bash

# Instructions: https://index.ros.org/doc/ros2/Installation/Linux-Install-Debians/
set -e

# flags
ROS_DISTRO="${ROS_DISTRO:-crystal}"
ROS_DISTRO_VARIANT="${ROS_DISTRO_VARIANT:-desktop}"
INSTALL_OPTIONAL="${INSTALL_OPTIONAL:-0}"
USE_ROS1_PKGS="${USE_ROS1_PKGS:-0}"  # additional packages for examples
INSTALL_BASHRC_LINE="${INSTALL_BASHRC_LINE:-0}"
INSTALL_EXTA_TOOLS="${INSTALL_EXTRA_TOOLS:-0}"  # for colcon etc.

function print_sec {
    printf "\n===============================================\n"
    printf "$1...\n"
    printf "===============================================\n\n"
}

if [[ "${ROS_DISTRO}" != "crystal" && "${ROS_DISTRO}" != "bouncy" && "${ROS_DISTRO}" != "ardent" ]]
then
    echo "[W] Unknown ROS distro provided [${ROS_DISTRO}]. Proceed cautiously...  <ENTER>"
    read
fi

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
sudo -E apt-get update && sudo -E apt-get install curl gnupg2 lsb-release
curl http://repo.ros2.org/repos.key | sudo -E apt-key add -
sudo -E sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'
sudo -E apt-get update
sudo -E apt-get install "ros-${ROS_DISTRO}-${ROS_DISTRO_VARIANT}"
# sudo -E apt-get install ros-$ROS_DISTRO-ros-base

if [[ "$INSTALL_OPTIONAL" == "1" ]]
then
    sudo -E apt-get install python3-pip
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
    sudo -E apt-get install ros-${ROS_DISTRO}-rmw-opensplice-cpp # for OpenSplice
    sudo -E apt-get install ros-${ROS_DISTRO}-rmw-connext-cpp # for RTI Connext (requires license agreement)
fi

if [[ $USE_ROS1_PKGS == "1" ]]
then
    print_sec "Installing ROS1 bridge"
    sudo -E apt-get install ros-${ROS_DISTRO}-ros1-bridge
fi

if [[ $USE_ROS1_PKGS == "1" ]]
then
    if [[ "${ROS_DISTRO}" != "crystal" ]]
    then
        print_sec "Installing turtlebot example2 packages"
        sudo -E apt-get install ros-${ROS_DISTRO}-turtlebot2-*
    else
        printf "[W] turtlebot2 packages not available for crystal yet...\n"
    fi
fi

if [[ $INSTALL_EXTA_TOOLS == "1" ]]
then
    print_sec "Installing additional tools"
    sudo -E apt-get install \
        python3-colcon-common-extensions \
        ros-${ROS_DISTRO}-tf2-*

    if [[ "${ROS_DISTRO}" != "ardent" ]]
    then
    sudo -E apt-get install \
        ros-${ROS_DISTRO}-rqt-* \
        ros-${ROS_DISTRO}-image-transport \
        ros-${ROS_DISTRO}-rviz2*
    fi
fi

print_sec "All done."
