

FROM nvidia/cuda:11.4.3-cudnn8-runtime-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND} \
    TZ=Asia/Tokyo

# タイムゾーン情報を先に設定
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone

RUN apt-get update && apt-get install -y \
      curl \
      gnupg2 \
      lsb-release \
      apt-transport-https \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. ROS apt リポジトリの鍵を HTTPS で取得し、trusted.gpg.d に配置
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
    | gpg --dearmor \
    > /usr/share/keyrings/ros-archive-keyring.gpg

# 3. sources.list にキーリングを指定して登録
RUN echo "deb [signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" \
    > /etc/apt/sources.list.d/ros-latest.list

# 必要なシミュレーション依存パッケージをまとめてインストール
RUN apt-get update && apt-get install -y \
    ros-noetic-desktop-full \
    nano \
    git \
    python3-catkin-tools \
    python3-rosdep \
    python3-vcstool \
    libyaml-cpp-dev \
    pkg-config \
    ros-noetic-ros-control \
    ros-noetic-ros-controllers \
    ros-noetic-gazebo-ros-control \
    ros-noetic-xacro \
  && rm -rf /var/lib/apt/lists/*

# rosdep 初期化
RUN rosdep init \
 && rosdep update


# 作業ディレクトリ設定
WORKDIR /root

# デフォルトシェル
CMD ["bash"]


