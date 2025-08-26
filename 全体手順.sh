

# 1) Docker_ReachabilityMapターミナル
docker rm -f irm_dev
docker run -d --name irm_dev -p 9090:9090 -v C:\Users\soma0\Docker_project\IRM_pro\Docker_ReachabilityMap:/root irm_dev tail -f /dev/null

docker exec -it irm_dev bash


# 1) youbootターミナル
docker rm -f youbot_pro
docker run -d --name youbot_pro -p 9092:9090 -v C:\Users\soma0\Docker_project\youbot_pro\Docker_Youbot_project_gradient:/root youbot_pro tail -f /dev/null

docker exec -it youbot_pro bash


# 実行（WSLg 連携
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

docker exec -it sim_dev bash

#########################################################

docker network create rosnet

docker network connect rosnet irm_dev
docker network connect rosnet sim_dev
docker network connect rosnet youbot_pro

#########################################################



# 2) Docker_ReachabilityMapターミナル
export ROS_MASTER_URI=http://ros_dev:11311
export ROS_HOSTNAME=ros_dev 
source /opt/ros/noetic/setup.bash
roslaunch rosbridge_server rosbridge_websocket.launch


cd RM
source devel/setup.bash
export ROS_MASTER_URI=http://ros_dev:11311
export ROS_HOSTNAME=ros_dev 

roslaunch sampled_reachability_maps MR_IRM_generate_Docker.launch
rosrun sampled_reachability_maps MR_IRM_firstRoute_fixed.py

cd Detect_ws
source devel/setup.bash
export ROS_MASTER_URI=http://ros_dev:11311
export ROS_HOSTNAME=ros_dev 

rosrun detect_pkg DetectTarget.py \
  --win=0.5,0.25,0.25 \
  --wout=0.21,0.58,0.21

rosrun detect_pkg Bottle_info_Save_to_CSV.py

cd ReIR_ws
source devel/setup.bash
export ROS_MASTER_URI=http://ros_dev:11311
export ROS_HOSTNAME=ros_dev 

dos2unix Get_RL_neccesary_data.py
dos2unix reward.py
rosrun RIR_pkg2 Get_RL_neccesary_data.py



# 2) Esaki_youbootターミナル
cd catkin_ws
source /opt/ros/noetic/setup.bash
export ROS_MASTER_URI=http://ros_dev:11311
export ROS_HOSTNAME=esaki_youbot
source devel/setup.bash

rosrun esaki_youbot_project_gradient youbot_real_trajectory_node.py
rosrun esaki_youbot_project_gradient youbot_real_recover_trajectory.py
rosrun esaki_youbot_project_gradient Bridge_Simulation_command.py

rosrun esaki_youbot_project_gradient Bridge_Simulation_gripper.py
rosrun esaki_youbot_project_gradient gripper.py



roslaunch esaki_slam youbot_move_base.launch
roslaunch slam_toolbox online_async.launch 

rosrun esaki_youbot_project_gradient Origin_move_pub.py 

rosrun esaki_youbot_project_gradient IRM_youbot_baseMove.py



chmod +x ~/catkin_ws/src/esaki_youbot_project_gradient/src/qp_posture_servo.py
sed -i 's/\r$//' ~/catkin_ws/src/esaki_youbot_project_gradient/src/qp_posture_servo.py
roslaunch esaki_youbot_project_gradient youbot_bringup.launch


# 2) simターミナル
docker exec -it sim_dev bash

export ROS_MASTER_URI=http://sim_dev:11311
export ROS_HOSTNAME=sim_dev
source devel/setup.bash

roslaunch youbot_gazebo_robot youbot_dual_arm.launch

roslaunch youbot_gazebo_robot youbot_dual_arm.launch world:=empty_world
roslaunch youbot_gazebo_robot youbot_dual_arm.launch world:=tower_of_hanoi
roslaunch youbot_gazebo_robot youbot_dual_arm.launch world:=robocup_at_work_2012


# 2) proターミナル
docker exec -it youbot_pro bash

export ROS_MASTER_URI=http://sim_dev:11311
export ROS_HOSTNAME=youbot_pro
source devel/setup.bash

rosrun esaki_youbot_project_gradient youbot_real_trajectory_node.py
rosrun esaki_youbot_project_gradient Bridge_Simulation_command.py