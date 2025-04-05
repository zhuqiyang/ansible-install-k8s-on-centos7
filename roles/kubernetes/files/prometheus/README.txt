创建pv pvc资源：
kubectl create ns prometheus
kubectl apply -f alertmanager-pv.yaml
kubectl apply -f prometheus-pv-pvc.yaml

此步骤 ansible-playbook 脚本已做,如果prometheus启动不了有可能是权限问题，手动操作下面步骤：
mkdir /data/prometheus/ -pv
chmod -R 755 /data/

安装：
tar -xf prometheus-23.1.0.tgz
cd prometheus/
helm install prometheus -n prometheus .

修改了如下几项：压缩包中的value.yaml已经修改,直接应用即可：
server:
  ...
  persistentVolume:
    enabled: true
    accessModes:
      - ReadWriteOnce
    existingClaim: "prometheus"
    mountPath: /data
    size: 30Gi

alertmanager:
  enabled: true
  persistence:
    size: 2Gi
