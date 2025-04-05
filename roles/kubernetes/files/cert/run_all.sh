#!/bin/bash

set -x

bash 00_create_csr.sh
bash 01_make_certs.sh
bash 02_create_kubeconfig.sh
