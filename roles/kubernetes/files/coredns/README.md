部署：
tar -xf coredns-1.24.1-helm.tgz
cd coredns
helm install coredns -n kube-system .

# 部署好后 
kubectl run -it --rm --restart=Never --image=harbor.k8s.local/infoblox/dnstools:latest dnstools

dnstools# nslookup kubernetes
Server:		10.96.0.10
Address:	10.96.0.10#53

Name:	kubernetes.default.svc.cluster.local
Address: 10.96.0.1

能解析出来就说明ok。
