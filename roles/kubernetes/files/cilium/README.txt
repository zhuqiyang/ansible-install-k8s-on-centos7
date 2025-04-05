Local Install:
解压：
tar -xf cilium-1.14.0.tgz

# 启用路由信息和监控插件
cd cilium
helm install cilium -n kube-system . --set hubble.relay.enabled=true --set hubble.ui.enabled=true --set prometheus.enabled=true --set operator.prometheus.enabled=true --set hubble.enabled=true --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}"


cilium专属监控: 用于测试，非必须
cd monitoring
kubectl apply -f monitoring-test-less.yaml
kubectl apply -f monitoring-test-prometheus-grafana.yaml
