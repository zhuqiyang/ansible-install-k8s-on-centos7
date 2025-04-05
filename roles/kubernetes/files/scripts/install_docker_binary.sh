#!/bin/bash


mkdir /root/docker/ -pv
cd /root/docker/

export DOCKER_DOWNLOAD_URL="https://download.docker.com/linux/static/stable/x86_64/docker-24.0.2.tgz"
export CRI_DOCKER_URL="https://ghproxy.com/https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.3/cri-dockerd-0.3.3.amd64.tgz"
export CNI_PLUGINS_URL="https://ghproxy.com/https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz"

export DOCKER_PACKAGE=`basename $DOCKER_DOWNLOAD_URL`
export CRI_DOCKER_PACKAGE=`basename $CRI_DOCKER_URL`
export CNI_PLUGINS_PACKAGE=`basename $CNI_PLUGINS_URL`



#if [ ! -f $DOCKER_PACKAGE ]; then
#    wget $DOCKER_DOWNLOAD_URL;
#fi
#
#if [ ! -f $CRI_DOCKER_PACKAGE ]; then
#    wget $CRI_DOCKER_URL;
#fi
#
#if [ ! -f $CNI_PLUGINS_PACKAGE ]; then
#    wget $CNI_PLUGINS_URL;
#fi


if [ -f $DOCKER_PACKAGE ]; then
    tar -xf $DOCKER_PACKAGE
    cp docker/* /usr/bin/
else
    echo file $DOCKER_PACKAGE not exists;
    exit;
fi

if [ -f $CRI_DOCKER_PACKAGE ]; then
    tar -xf $CRI_DOCKER_PACKAGE
    cp -r cri-dockerd/  /usr/bin/
    chmod +x /usr/bin/cri-dockerd/cri-dockerd
else
    echo file $CRI_DOCKER_PACKAGE not exists;
    exit;
fi

if [ -f $CNI_PLUGINS_PACKAGE ]; then
    mkdir -pv /etc/cni/{net.d,bin}
    mkdir -pv /opt/cni/bin/
    tar -xf $CNI_PLUGINS_PACKAGE -C /opt/cni/bin/
else
    echo file $CNI_PLUGINS_PACKAGE not exists;
    exit;
fi


if [ ! -f /etc/sysctl.d/99-kubernetes-cri.conf ]; then
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl -p
fi

if [ ! -f /etc/modules-load.d/containerd.conf ]; then
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
systemctl restart systemd-modules-load.service
fi


# install containerd
cat > /etc/systemd/system/containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF




# install docker service
cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF


# install docker socket
cat > /etc/systemd/system/docker.socket <<EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

mkdir /etc/docker/ -pv
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "http://hub-mirror.c.163.com"
  ],
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
    },
  "data-root": "/var/lib/docker"
}
EOF





# install cri-docker service
cat >  /usr/lib/systemd/system/cri-docker.service <<EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/cri-dockerd/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.9
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

StartLimitBurst=3
StartLimitInterval=60s

LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF


# install cri-docker socket
cat > /usr/lib/systemd/system/cri-docker.socket <<EOF
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service

[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF



groupadd docker
systemctl daemon-reload

systemctl enable containerd.service

systemctl enable docker.service
systemctl enable docker.socket

systemctl enable cri-docker.service
systemctl enable cri-docker.socket

systemctl restart containerd.service
systemctl restart docker.socket
systemctl restart docker.service
systemctl restart cri-docker.socket
systemctl restart cri-docker.service

systemctl status containerd.service -n0
systemctl status docker.socket -n0
systemctl status docker.service -n0
systemctl status cri-docker.socket -n0
systemctl status cri-docker.service -n0

