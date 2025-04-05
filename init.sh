#!/bin/bash
########################
#                      #
#    修改下面的变量    #
#                      #
########################



# 域名后缀
export DOMAIN_SUFFIX=k8s.local
# 泛域名，用于生成证书
export COMMON_WILDCARD_DOMAIN_NAME=*.${DOMAIN_SUFFIX}
# keepalived 的 vip 或域名
export COMMON_LOAD_BALANCE_HOSTNAME=master.${DOMAIN_SUFFIX}
# keepalived vip
export KEEPALIVED_VIP=192.168.0.159
# keepalived 配置vip的值
export KEEPALIVED_VIP_CIDR_NETMASK=24
# keepalived vrrp router id 同一个网段的两个keepalived集群这个vrid不要相同
export KEEPALIVED_ROUTER_ID=$(( RANDOM % 255 + 1 ))
# 高可用ip的端口或域名的端口,
# 如果安装haproxy则端口一定不能是6443,因为与apiserver端口冲突
export COMMON_LOAD_BALANCE_PORT=8443

# 各节点信息
export MASTER01_IP=192.168.0.151
export MASTER01_HOSTNAME=master01.${DOMAIN_SUFFIX}
export MASTER01_ETCD01_HOSTNAME=etcd01.${DOMAIN_SUFFIX}

export MASTER02_IP=192.168.0.152
export MASTER02_HOSTNAME=master02.${DOMAIN_SUFFIX}
export MASTER02_ETCD02_HOSTNAME=etcd02.${DOMAIN_SUFFIX}

export MASTER03_IP=192.168.0.153
export MASTER03_HOSTNAME=master03.${DOMAIN_SUFFIX}
export MASTER03_ETCD03_HOSTNAME=etcd03.${DOMAIN_SUFFIX}

# 时间同步服务器ip地址或域名，例：ntp.aliyun.com
export TIME_SERVER_ADDRESS=ntp.aliyun.com

# harbor地址和ip
export HARBOR_IP=192.168.0.61
export HARBOR_HOSTNAME=harbor.${DOMAIN_SUFFIX}

# 容器运行时 docker or containerd
export CONTAINER_RUNTIME=docker
# docker 数据存储目录，留空则默认在/var/lib/docker目录
export DOCKER_DATA_ROOT=/var/lib/docker


# Pod网络 '172.16.0.0/12' or '10.244.0.0/16'
export POD_NETWORK='10.244.0.0/16'
# service 网络
# 如果 SERVICE_NETWORK 使用的网段不是 10.96.0.0/12，
# 则需要在创建证书处添加对应网段的ip，
# 示例如下：
#     10.96.0.0/12   -> kubernetes -> 10.96.0.1
#     172.16.0.1/16  -> kubernetes -> 172.16.0.1
#     192.168.0.1/16 -> kubernetes -> 192.168.0.1
#     要把这个 x.x.0.1 的ip添加到证书中去,否者集群网络无法工作。
export SERVICE_NETWORK='172.16.0.0/16'
# k8s内DNS服务IP
export DNS_CLUSTERIP='172.16.0.10'









####################################
#                                  #
#  下面的内容是自动生成，不用修改  #
#                                  #
####################################



# 生成hosts文件
cat > hosts <<EOF
[k8smaster]
${MASTER01_HOSTNAME} ansible_host=${MASTER01_IP} etcd_hostname=${MASTER01_ETCD01_HOSTNAME} sn=1 
${MASTER02_HOSTNAME} ansible_host=${MASTER02_IP} etcd_hostname=${MASTER02_ETCD02_HOSTNAME} sn=2 
${MASTER03_HOSTNAME} ansible_host=${MASTER03_IP} etcd_hostname=${MASTER03_ETCD03_HOSTNAME} sn=3

[k8smaster:vars]
etcd01_hostname=${MASTER01_ETCD01_HOSTNAME}
etcd02_hostname=${MASTER02_ETCD02_HOSTNAME}
etcd03_hostname=${MASTER03_ETCD03_HOSTNAME}
master01_hostname=${MASTER01_HOSTNAME}
master02_hostname=${MASTER02_HOSTNAME}
master03_hostname=${MASTER03_HOSTNAME}

[k8snodes]
#node01.${DOMAIN_SUFFIX} ansible_host=192.168.0.59
EOF
cat hosts


# 变量文件
cat > vars.yml <<EOF
# 这两个大写的变量是用在生成ssl证书的脚本里的
# 泛域名，用于生成证书
COMMON_WILDCARD_DOMAIN_NAME: '${COMMON_WILDCARD_DOMAIN_NAME}'
# keepalived 的 vip 或域名
COMMON_LOAD_BALANCE_HOSTNAME: '${COMMON_LOAD_BALANCE_HOSTNAME}'
# 高可用ip的端口或域名的端口
COMMON_LOAD_BALANCE_PORT: '${COMMON_LOAD_BALANCE_PORT}'

# 容器运行时 docker or containerd
container_runtime: '${CONTAINER_RUNTIME}'
# docker 数据存储目录，默认在/var/lib/docker目录
docker_data_root: '${DOCKER_DATA_ROOT}'

# 设置 keepalived 的 master 节点
keepalived_master: '${MASTER01_HOSTNAME}'
# keepalived vip
keepalived_vip: '${KEEPALIVED_VIP}'
# keepalived vip netmask
keepalived_vip_netmask: '${KEEPALIVED_VIP_CIDR_NETMASK}'
# keepalived vrrp router id
keepalived_router_id: '${KEEPALIVED_ROUTER_ID}'
# 时间同步服务器
time_server_address: '${TIME_SERVER_ADDRESS}'

# Pod网络 '172.16.0.0/12' or '10.244.0.0/16'
pod_network: '${POD_NETWORK}'
# service 网络
service_network: '${SERVICE_NETWORK}'
# k8s内部dns ip地址，coredns ip address
dns_clusterip: '${DNS_CLUSTERIP}'

# 镜像仓库harbor的地址
harbor_hostname: '${HARBOR_HOSTNAME}'

# k8s所有节点的IP，用于写入到证书中，多个IP使用逗号分格
COMMON_K8S_IPS: '${MASTER01_IP},${MASTER02_IP},${MASTER03_IP},${KEEPALIVED_VIP},'

# 各个节点的DNS解析
hosts:
- { ip_address: '${MASTER01_IP}', name: '${MASTER01_HOSTNAME}', alias: '${MASTER01_ETCD01_HOSTNAME}' }
- { ip_address: '${MASTER02_IP}', name: '${MASTER02_HOSTNAME}', alias: '${MASTER02_ETCD02_HOSTNAME}' }
- { ip_address: '${MASTER03_IP}', name: '${MASTER03_HOSTNAME}', alias: '${MASTER03_ETCD03_HOSTNAME}' }
- { ip_address: '${KEEPALIVED_VIP}', name: '${COMMON_LOAD_BALANCE_HOSTNAME}', alias: '' }
- { ip_address: '${HARBOR_IP}', name: '${HARBOR_HOSTNAME}', alias: '' }
EOF
cat vars.yml

