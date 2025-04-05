#!/bin/bash
############################
#                          #
#    install containerd    #
#                          #
############################


export CNI_PLUGINS_URL="https://ghproxy.com/https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz"
export CRI_CONTAINERD_URL="https://ghproxy.com/https://github.com/containerd/containerd/releases/download/v1.7.2/cri-containerd-cni-1.7.2-linux-amd64.tar.gz"
export CRICTL_URL="https://ghproxy.com/https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.24.2/crictl-v1.24.2-linux-amd64.tar.gz"

export CNI_PLUGINS_PACKAGE=`basename $CNI_PLUGINS_URL`
export CRI_CONTAINERD_PACKAGE=`basename $CRI_CONTAINERD_URL`
export CRICTL_PACKAGE=`basename $CRICTL_URL`


cd /root/containerd/

#if [ ! -f $CNI_PLUGINS_PACKAGE ]; then
#    wget $CNI_PLUGINS_URL;
#fi
#
#if [ ! -f $CRI_CONTAINERD_PACKAGE ]; then
#    wget $CRI_CONTAINERD_URL;
#fi
#
#if [ ! -f $CRICTL_PACKAGE ]; then
#    wget $CRICTL_URL;
#fi


if [ -f $CNI_PLUGINS_PACKAGE ]; then
    mkdir -pv /etc/cni/{net.d,bin}
    mkdir -pv /opt/cni/bin/
    tar -xf $CNI_PLUGINS_PACKAGE -C /opt/cni/bin/
fi

if [ -f $CRI_CONTAINERD_PACKAGE ]; then
    tar -xf $CRI_CONTAINERD_PACKAGE -C /
fi

if [ -f $CRICTL_PACKAGE ]; then
    tar -xf $CRICTL_PACKAGE -C /usr/bin/
fi


if [ ! -f /etc/modules-load.d/containerd.conf ]; then
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
systemctl restart systemd-modules-load.service
fi

if [ ! -f /etc/sysctl.d/99-kubernetes-cri.conf ]; then
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl -p
fi


cat > /usr/lib/systemd/system/containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF


mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

sed -i "s#SystemdCgroup\ \=\ false#SystemdCgroup\ \=\ true#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep SystemdCgroup

sed -i "s#registry.k8s.io#registry.aliyuncs.com/google_containers#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep sandbox_image

sed -i 's#config_path\ \=\ \"\"#config_path\ \=\ \"/etc/containerd/certs.d\"#g' /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep certs.d


# 配置加速器
mkdir /etc/containerd/certs.d/docker.io -pv
cat > /etc/containerd/certs.d/docker.io/hosts.toml << EOF
server = "https://docker.io"
[host."https://hub-mirror.c.163.com"]
  capabilities = ["pull", "resolve"]
EOF


systemctl daemon-reload
systemctl enable containerd
#systemctl restart containerd

