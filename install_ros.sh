#!/usr/bin/env bash
set -e

ROS_DISTRO="${1:-melodic}"
INSTALLATION_TYPE="${2:-desktop-full}"

ROS_WS="$HOME/ros_ws"

# Sources list, apt-key
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 0xB01FA116

sudo apt-get update

# Install ROS packages
sudo apt-get install -y "ros-${ROS_DISTRO}-${INSTALLATION_TYPE}"

# Initialize rosdep
sudo rosdep init
rosdep update

# Rosinstall installation
sudo apt-get install -y python-rosinstall

# catkin
sudo apt-get install -y python-catkin-tools

# Source config file
source /opt/ros/$ROS_DISTRO/setup.bash
echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> "$HOME/.bashrc"

echo "Setting up basic workspace..."
oldpwd="$PWD"
mkdir -p "$ROS_WS/src"
cd "$ROS_WS"

source "$HOME/.bashrc"
catkin_init_workspace
catkin build
cd "$oldpwd"

echo "source $ROS_WS/devel/setup.bash" >> "$HOME/.bashrc"
echo "Remember to source your .bashrc to apply the changes..."
