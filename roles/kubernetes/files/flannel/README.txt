部署flannel之前集群处于NotReady状态，因为网络插件cni的配置文件被删除了，部署上flannel即可恢复Ready状态。

kubectl apply -f kube-flannel.yml
