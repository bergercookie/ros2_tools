if [[  $# != 2 ]]; then
    name="${BASH_SOURCE[*]}"
    echo "Usage: $name <ros-version-to-install> <desktop-full|desktop|ros-base>"
    exit 1
fi

ROS_DISTRO="${1:-kinetic}"
INSTALLATION_TYPE="${2:-desktop-full}"

# Sources list, apt-key
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 0xB01FA116

sudo apt-get update

# Install ROS packages
sudo apt-get install "ros-${ROS_DISTRO}-${INSTALLATION_TYPE}"

# Initialize rosdep
sudo rosdep init
rosdep update

# Source config file
source /opt/ros/$(ROS_DISTRO)/setup.bash

# Rosinstall installation
sudo apt-get install python-rosinstall
