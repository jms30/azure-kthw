#!/usr/bin/env bash

KUBERNETES_PUBLIC_ADDRESS=8.8.8.8             ###ADD IP ADDRESS OF YOUR AZURE LOAD BALANCER HERE 
CLUSTER_NAME="kubernetes-the-hard-way"
CONFIG_FILE_PATH=../kubernetes_setup_files

CWD=$(pwd)

cd ${CONFIG_FILE_PATH}


kubectl config set-cluster $CLUSTER_NAME \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443
kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem
kubectl config set-context $CLUSTER_NAME \
  --cluster=$CLUSTER_NAME \
  --user=admin
kubectl config use-context $CLUSTER_NAME

cd ${CWD}
