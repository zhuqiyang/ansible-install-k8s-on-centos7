#!/bin/bash

source ssl_vars.sh

export CSR_DIR=${COMMON_CSR_DIR:=csr}
export ETCD_HOSTNAME=${COMMON_WILDCARD_DOMAIN_NAME:=*.k8s.local}
export K8S_HOSTNAME=${COMMON_WILDCARD_DOMAIN_NAME=:*.k8s.local}
export ETCD_CERT_DIR=${COMMON_ETCD_CERT_DIR:=etcd-cert}
export K8S_CERT_DIR=${COMMON_K8S_CERT_DIR:=k8s-cert}
export K8S_IPS=${COMMON_K8S_IPS:=}


if [ -d ${ETCD_CERT_DIR} ]; then
    rm ${ETCD_CERT_DIR} -rf
fi
mkdir ${ETCD_CERT_DIR} -pv


if [ -d ${K8S_CERT_DIR} ]; then
    rm ${K8S_CERT_DIR} -rf
fi
mkdir ${K8S_CERT_DIR} -pv



echo -e "\nGenerate etcd certificate:"
cfssl gencert -initca ${CSR_DIR}/etcd-ca-csr.json | cfssljson -bare ${ETCD_CERT_DIR}/etcd-ca
cfssl gencert \
   -ca=${ETCD_CERT_DIR}/etcd-ca.pem \
   -ca-key=${ETCD_CERT_DIR}/etcd-ca-key.pem \
   -config=${CSR_DIR}/ca-config.json \
   -hostname=127.0.0.1,10.96.0.1,172.16.0.1,192.168.0.1,${K8S_IPS}localhost,$ETCD_HOSTNAME \
   -profile=kubernetes \
   ${CSR_DIR}/etcd-csr.json | cfssljson -bare ${ETCD_CERT_DIR}/etcd


echo -e "\nGenerate k8s ca certificate:"
cfssl gencert -initca ${CSR_DIR}/ca-csr.json | cfssljson -bare ${K8S_CERT_DIR}/ca
echo -e "\nGenerate apiserver certificate:"
cfssl gencert \
    -ca=${K8S_CERT_DIR}/ca.pem \
    -ca-key=${K8S_CERT_DIR}/ca-key.pem \
    -config=${CSR_DIR}/ca-config.json \
    -hostname=10.96.0.1,172.16.0.1,192.168.0.1,127.0.0.1,${K8S_IPS}localhost,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local,${K8S_HOSTNAME} \
    -profile=kubernetes ${CSR_DIR}/apiserver-csr.json | cfssljson -bare ${K8S_CERT_DIR}/apiserver


echo -e "\nGenerate front-proxy-ca certificate:"
cfssl gencert -initca ${CSR_DIR}/front-proxy-ca-csr.json | cfssljson -bare ${K8S_CERT_DIR}/front-proxy-ca 
echo -e "\nGenerate front-proxy-client certificate:"
cfssl gencert \
    -ca=${K8S_CERT_DIR}/front-proxy-ca.pem   \
    -ca-key=${K8S_CERT_DIR}/front-proxy-ca-key.pem   \
    -config=${CSR_DIR}/ca-config.json   \
    -profile=kubernetes ${CSR_DIR}/front-proxy-client-csr.json | cfssljson -bare ${K8S_CERT_DIR}/front-proxy-client

echo -e "\nGenerate controller-manager certificate:"
cfssl gencert \
   -ca=${K8S_CERT_DIR}/ca.pem \
   -ca-key=${K8S_CERT_DIR}/ca-key.pem \
   -config=${CSR_DIR}/ca-config.json \
   -profile=kubernetes \
   ${CSR_DIR}/manager-csr.json | cfssljson -bare ${K8S_CERT_DIR}/controller-manager

echo -e "\nGenerate scheduler certificate:"
cfssl gencert \
   -ca=${K8S_CERT_DIR}/ca.pem \
   -ca-key=${K8S_CERT_DIR}/ca-key.pem \
   -config=${CSR_DIR}/ca-config.json \
   -profile=kubernetes \
   ${CSR_DIR}/scheduler-csr.json | cfssljson -bare ${K8S_CERT_DIR}/scheduler

echo -e "\nGenerate admin certificate:"
cfssl gencert \
   -ca=${K8S_CERT_DIR}/ca.pem \
   -ca-key=${K8S_CERT_DIR}/ca-key.pem \
   -config=${CSR_DIR}/ca-config.json \
   -profile=kubernetes \
   ${CSR_DIR}/admin-csr.json | cfssljson -bare ${K8S_CERT_DIR}/admin

echo -e "\nGenerate kube-proxy certificate:"
cfssl gencert \
   -ca=${K8S_CERT_DIR}/ca.pem \
   -ca-key=${K8S_CERT_DIR}/ca-key.pem \
   -config=${CSR_DIR}/ca-config.json \
   -profile=kubernetes \
   ${CSR_DIR}/kube-proxy-csr.json | cfssljson -bare ${K8S_CERT_DIR}/kube-proxy

echo -e "\nGenerate sa.key sa.pub:"
openssl genrsa -out ${K8S_CERT_DIR}/sa.key 2048
openssl rsa -in ${K8S_CERT_DIR}/sa.key -pubout -out ${K8S_CERT_DIR}/sa.pub


