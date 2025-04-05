#!/bin/bash

files=(
/usr/local/bin/etcd
/usr/local/kubernetes/kube-apiserver
/usr/local/kubernetes/kube-controller-manager
/usr/local/kubernetes/kubelet
/usr/local/kubernetes/kube-proxy
/usr/local/kubernetes/kube-scheduler
)

for file in "${files[@]}"
do
    if [ ! -e "$file" ]; then
        echo -n "KubernetesNotInstalled"
        exit;
    fi
done
echo -n "KubernetesInstalled"
