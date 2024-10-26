# Copyright 2021 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# A Docker configuration script to build the Navigation2/Space ROS image.
#
# The script provides the following build arguments:
#
#   VCS_REF         - The git revision of the Space ROS source code (no default value).
#   SPACE_ROS_IMAGE - The base Space ROS image to build on

FROM osrf/space-ros:latest

ARG VCS_REF

# Specify the docker image metadata
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="Space ROS - Navigation2"
LABEL org.label-schema.description="Space ROS image with the Navigation2 stack"
LABEL org.label-schema.vendor="Open Robotics"
LABEL org.label-schema.url="https://github.com/space-ros"
LABEL org.label-schema.vcs-url="https://github.com/space-ros/docker"
LABEL org.label-schema.stacks-vcs-ref=${VCS_REF}

ENV DEBIAN_FRONTEND=noninteractive
ENV NAV2_DIR=/opt/spaceros-stacks/navigation2

SHELL ["/bin/bash", "-c"]

WORKDIR /workspace
RUN sudo chown spaceros-user:spaceros-user /workspace \
    && sudo mkdir -p /opt/spaceros-stacks \
    && sudo chown spaceros-user:spaceros-user /opt/spaceros-stacks

# Install dependencies for the image
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    sudo apt update \
    && sudo apt install -y python3-vcstool python3-colcon-common-extensions python3-rosdep \
    && sudo rosdep init \
    && rosdep update

# Clone all space-ros sources
COPY navigation2.repos .
COPY excluded-pkgs.txt .

RUN mkdir -p src \
    && vcs import --shallow src < navigation2.repos

# Manage dependencies for the Navigation2 stack
RUN source ${SPACEROS_DIR}/setup.bash \
    && sudo apt update \
    && rosdep install -y \
    --from-paths src --ignore-src \
    --skip-keys $(cat excluded-pkgs.txt) \
    --rosdistro ${ROS_DISTRO}

# Build the Navigation2 stack
RUN source ${SPACEROS_DIR}/setup.bash \
    && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON --no-warn-unused-cli \
    -DCMAKE_CXX_FLAGS="--param ggc-min-expand=20" --parallel-workers 4 \
    --install-base ${NAV2_DIR} --merge-install --event-handlers console_direct+ --packages-ignore $(cat excluded-pkgs.txt)

# Define key locations and setup entrypoint
RUN echo "source ${NAV2_DIR}/setup.bash" >> /opt/spaceros-stacks/setup.bash \
    && echo "source /opt/spaceros-stacks/setup.bash" >> ${HOME}/.bashrc
RUN mkdir -p /opt/spaceros-stacks/scripts/ \
    && vcs export --exact src > /opt/spaceros-stacks/scripts/spaceros-nav2.repos

# Cleanup dependencies and sources
RUN sudo apt remove python3-vcstool python3-colcon-common-extensions python3-rosdep -y \
    && sudo apt autoremove -y \
    && sudo apt clean \
    && sudo rm -rf /var/lib/apt/lists/* \
    && sudo rm -rf /var/cache/apt \
    && sudo rm -rf /workspace/*

WORKDIR ${HOME}

CMD ["bash"]
