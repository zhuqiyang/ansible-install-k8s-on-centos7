#!/bin/bash

files=(
/usr/local/kubernetes/kubelet
/usr/local/kubernetes/kube-proxy
)

for file in "${files[@]}"
do
    if [ ! -e "$file" ]; then
        echo -n "NodeIsNotOk"
        exit;
    fi
done
echo -n "NodeOk"
