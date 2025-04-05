版本：
ingress-nginx-4.7.1-helm-chart.tgz


helm安装: 

打ingress=true标签
for var in `kubectl get nodes | grep -v 'NAME' | awk '{print $1}'`; do kubectl label node $var ingress=true; done

kubectl create ns ingress-nginx

cd ingress-nginx/
helm install ingress-nginx -n ingress-nginx .

删掉下面这个验证资源
kubectl delete validatingwebhookconfigurations ingress-nginx-admission

测试：
kubectl apply -f ingress-test.yaml

grafana dashboard：
grafana id: 9614

