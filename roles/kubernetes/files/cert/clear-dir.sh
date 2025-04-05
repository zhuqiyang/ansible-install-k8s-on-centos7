#!/bin/bash

source ssl_vars.sh


if [ -d ${COMMON_CSR_DIR} ]; then
    rm ${COMMON_CSR_DIR} -rf
fi


if [ -d ${COMMON_ETCD_CERT_DIR} ]; then
    rm ${COMMON_ETCD_CERT_DIR} -rf
fi


if [ -d ${COMMON_K8S_CERT_DIR} ]; then
    rm ${COMMON_K8S_CERT_DIR} -rf
fi


if [ -d ${COMMON_KUBECONFIG_DIR} ]; then
    rm ${COMMON_KUBECONFIG_DIR} -rf
fi


rm ssl_vars.sh -rf
