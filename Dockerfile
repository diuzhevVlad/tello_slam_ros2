FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Minsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt-get update
RUN apt install git tmux -y

COPY ./tello-ros2 /tello-ros2

WORKDIR /tello-ros2

RUN apt install build-essential gdb -y
RUN apt update && apt install -y locales && locale-gen en_US en_US.UTF-8 && \
	update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
	export LANG=en_US.UTF-8
	
RUN apt update && apt install -y curl gnupg2 lsb-release 
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

RUN apt update && apt install -y ros-foxy-desktop

RUN source /opt/ros/foxy/setup.bash

# Argcomplete
RUN apt install -y python3-pip
RUN pip3 install -U argcomplete

# Colcon build tools
RUN apt install -y python3-colcon-common-extensions python3-rosdep2

# Update ROS dep
RUN rosdep update && rosdep fix-permissions

# Add to bashrc
RUN echo "source /opt/ros/foxy/setup.bash" >> ~/.bashrc && \
	echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc && \
	echo "export _colcon_cd_root=~/ros2_install" >> ~/.bashrc && \
	source ~/.bashrc

# Install project dependencies
RUN pip3 install catkin_pkg rospkg av image opencv-python djitellopy2 pyyaml
RUN apt install -y python3-tf*


RUN apt install -y ros-foxy-ament-cmake* ros-foxy-tf2* ros-foxy-rclcpp* ros-foxy-rosgraph*

RUN apt install -y ros-foxy-rviz* ros-foxy-rqt*

RUN ./scripts/opencv.sh
RUN ./scripts/cameracalib.sh
RUN ./scripts/gazebo.sh
RUN ./scripts/orbslam.sh
