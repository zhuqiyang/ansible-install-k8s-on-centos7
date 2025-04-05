#!/bin/bash

source ssl_vars.sh

export K8S_CERT_DIR=${COMMON_K8S_CERT_DIR:=k8s-cert}
export KUBECONFIG_DIR=${COMMON_KUBECONFIG_DIR:=kubeconfigs}
export SERVER_URL=https://${COMMON_LOAD_BALANCE_HOSTNAME:=master.k8s.local}:${COMMON_LOAD_BALANCE_PORT:=8443}

# for bootstrap-kubelet.kubeconfig
export KUBECONFIG=${KUBECONFIG_DIR}/bootstrap-kubelet.kubeconfig
export TOKEN=c8ad9c.2e4d610cf3e7426e


if [ -d ${KUBECONFIG_DIR} ]; then
    rm ${KUBECONFIG_DIR} -rf
fi
mkdir ${KUBECONFIG_DIR} -pv


echo -e "\nCreate controller-manager.kubeconfig"
kubectl --kubeconfig=${KUBECONFIG_DIR}/controller-manager.kubeconfig config set-cluster kubernetes --certificate-authority=${K8S_CERT_DIR}/ca.pem --embed-certs=true --server=${SERVER_URL}
kubectl --kubeconfig=${KUBECONFIG_DIR}/controller-manager.kubeconfig config set-context system:kube-controller-manager@kubernetes --cluster=kubernetes --user=system:kube-controller-manager
kubectl --kubeconfig=${KUBECONFIG_DIR}/controller-manager.kubeconfig config set-credentials system:kube-controller-manager --client-certificate=${K8S_CERT_DIR}/controller-manager.pem --client-key=${K8S_CERT_DIR}/controller-manager-key.pem --embed-certs=true
kubectl --kubeconfig=${KUBECONFIG_DIR}/controller-manager.kubeconfig config use-context system:kube-controller-manager@kubernetes


echo -e "\nCreate scheduler.kubeconfig"
kubectl --kubeconfig=${KUBECONFIG_DIR}/scheduler.kubeconfig config set-cluster kubernetes --certificate-authority=${K8S_CERT_DIR}/ca.pem --embed-certs=true --server=${SERVER_URL}
kubectl --kubeconfig=${KUBECONFIG_DIR}/scheduler.kubeconfig config set-credentials system:kube-scheduler --client-certificate=${K8S_CERT_DIR}/scheduler.pem --client-key=${K8S_CERT_DIR}/scheduler-key.pem --embed-certs=true
kubectl --kubeconfig=${KUBECONFIG_DIR}/scheduler.kubeconfig config set-context system:kube-scheduler@kubernetes --cluster=kubernetes --user=system:kube-scheduler
kubectl --kubeconfig=${KUBECONFIG_DIR}/scheduler.kubeconfig config use-context system:kube-scheduler@kubernetes


echo -e "\nCreate admin.kubeconfig"
kubectl --kubeconfig=${KUBECONFIG_DIR}/admin.kubeconfig config set-cluster kubernetes --certificate-authority=${K8S_CERT_DIR}/ca.pem --embed-certs=true --server=${SERVER_URL}
kubectl --kubeconfig=${KUBECONFIG_DIR}/admin.kubeconfig config set-credentials kubernetes-admin --client-certificate=${K8S_CERT_DIR}/admin.pem --client-key=${K8S_CERT_DIR}/admin-key.pem --embed-certs=true
kubectl --kubeconfig=${KUBECONFIG_DIR}/admin.kubeconfig config set-context kubernetes-admin@kubernetes --cluster=kubernetes --user=kubernetes-admin
kubectl --kubeconfig=${KUBECONFIG_DIR}/admin.kubeconfig config use-context kubernetes-admin@kubernetes


echo -e "\nCreate kube-proxy.kubeconfig"
kubectl --kubeconfig=${KUBECONFIG_DIR}/kube-proxy.kubeconfig config set-cluster kubernetes --certificate-authority=${K8S_CERT_DIR}/ca.pem --embed-certs=true --server=${SERVER_URL}
kubectl --kubeconfig=${KUBECONFIG_DIR}/kube-proxy.kubeconfig config set-credentials kube-proxy --client-certificate=${K8S_CERT_DIR}/kube-proxy.pem --client-key=${K8S_CERT_DIR}/kube-proxy-key.pem --embed-certs=true
kubectl --kubeconfig=${KUBECONFIG_DIR}/kube-proxy.kubeconfig config set-context kube-proxy@kubernetes --cluster=kubernetes --user=kube-proxy
kubectl --kubeconfig=${KUBECONFIG_DIR}/kube-proxy.kubeconfig config use-context kube-proxy@kubernetes


echo -e "\nCreate bootstrap-kubelet.kubeconfig"
kubectl --kubeconfig=${KUBECONFIG} config set-cluster kubernetes --certificate-authority=${K8S_CERT_DIR}/ca.pem --embed-certs=true --server=${SERVER_URL}
kubectl --kubeconfig=${KUBECONFIG} config set-credentials tls-bootstrap-token-user --token=${TOKEN}
kubectl --kubeconfig=${KUBECONFIG} config set-context tls-bootstrap-token-user@kubernetes --cluster=kubernetes --user=tls-bootstrap-token-user
kubectl --kubeconfig=${KUBECONFIG} config use-context tls-bootstrap-token-user@kubernetes


