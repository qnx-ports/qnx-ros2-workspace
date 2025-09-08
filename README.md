Setting up a workspace for ROS2 Jazzy for QNX:

Pre-requisite: build and install QNX ROS2 Jazzy from [source](https://github.com/qnx-ports/build-files/blob/main/ports/ros2/ros2-jazzy/README.md).                                     

Preferable host OS: Ubuntu 20.04

0. Optional: use [Docker](https://github.com/qnx-ports/build-files/blob/main/docker/README.md) to have a consistent build environment.

1. Clone the sample workspace:
```bash
git clone https://github.com/qnx-ports/qnx-ros2-workspace.git && cd qnx-ros2-workspace
```

2. This repository has a hello_qnx in src as an example. Add your packages inside src.

3. Run the build command:
```bash
# Specify the architecture to build
export CPU=aarch64

# Specify your ros2 host installation path
export ROS2_HOST_INSTALLATION_PATH=$QNX_TARGET/aarch64le/opt/ros/jazzy
./build.sh
```

4. On target create a new directory for your group of packages:
```bash
mkdir -p /data/home/qnxuser/opt/ros/nodes

# Run chmod a+w to /data/home/qnxuser/opt if you created it as root
chmod a+w -R /data/home/qnxuser/opt
```

5. Copy your packages over to the new location:
```bash
TARGET_IP_ADDRESS=<target-ip-address>

scp -r ./install/aarch64le/* qnxuser@$TARGET_IP_ADDRESS:/data/home/qnxuser/opt/ros/nodes

# Make sure to copy over jazzy if you haven't already
scp -r ~/qnx800/target/qnx/aarch64le/opt/ros/jazzy qnxuser@$TARGET_IP_ADDRESS:/data/home/qnxuser/opt/ros/
```

6. Install required python packages on your target:
```bash
# Update system time
ntpdate -sb 0.pool.ntp.org 1.pool.ntp.org

# Install pip and packaging
mkdir -p /data
export TMPDIR=/data
python3 -m ensurepip
# Add pip to PATH
export PATH=$PATH:/data/home/qnxuser/.local/bin
pip3 install argcomplete packaging pyyaml lark -t /data/home/qnxuser/.local/lib/python3.11/site-packages/
export PYTHONPATH=$PYTHONPATH:/data/home/qnxuser/opt/ros/jazzy/usr/lib/python3.11/site-packages/:/data/home/qnxuser/.local/lib/python3.11/site-packages/
export COLCON_PYTHON_EXECUTABLE=/system/bin/python3
```

7. Run setup scripts:
```bash
export COLCON_PYTHON_EXECUTABLE=/system/bin/python3
cd /data/home/qnxuser/opt/ros/jazzy
. setup.bash
cd /data/home/qnxuser/opt/ros/nodes
. local_setup.bash
```

8. Run your newly installed packages.
```bash
ros2 run hello_qnx hello_qnx
[INFO] [1717543110.122714926] [hello_qnx]: Hello QNX!
```
