keepalived如果不需要安装只需注释掉,到文件16.2_install_master_docker_runtime.yml中去注释

1、安装master前执行init.sh脚本来生成hosts、vars.yml文件.
    添加node节点时则不可再次执行init.sh文件。
2、生成k8s证书。
install_cert.yml
3、部署k8s主节点，中间会重启，重启后再次执行install_master.yml脚本即可。
install_master.yml 
4、添加node节点
install_nodes.yml

添加节点后注意同步各个节点的hosts解析文件。

其他：
1、注意机器时间问题,时间服务器
2、升级完kernel必须要重启
3、注意cilium网段要修改

