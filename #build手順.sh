#build
docker build -t sim_dev .

#実行
docker rm -f sim_dev 2>/dev/null

docker run --gpus all -d --name sim_dev \
  --device /dev/dxg \
  -e DISPLAY=$DISPLAY \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -e PULSE_SERVER=${PULSE_SERVER:-unix:${XDG_RUNTIME_DIR}/pulse/native} \
  -e LD_LIBRARY_PATH=/usr/lib/wsl/lib:$LD_LIBRARY_PATH \
  -e LIBGL_DRIVERS_PATH=/usr/lib/wsl/lib:/usr/lib/x86_64-linux-gnu/dri \
  -e DRI_DRIVER=d3d12 \
  -e MESA_LOADER_DRIVER_OVERRIDE=d3d12 \
  -e MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA \
  -e QT_X11_NO_MITSHM=1 \
  --shm-size=2g \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY \
  -v $XDG_RUNTIME_DIR/pulse:$XDG_RUNTIME_DIR/pulse \
  -v /mnt/wslg:/mnt/wslg \
  -v /usr/lib/wsl:/usr/lib/wsl:ro \
  -v /mnt/c/Users/soma0/youbot_sim:/root \
  sim_dev tail -f /dev/null


#-v /mnt/c/Users/soma0/youbot_sim:/root \を自分のディレクトリに合わせる

docker exec -it sim_dev bash



docker exec -it sim_dev bash

export ROS_MASTER_URI=http://sim_dev:11311
export ROS_HOSTNAME=sim_dev
source devel/setup.bash

roslaunch youbot_gazebo_robot youbot_dual_arm.launch

