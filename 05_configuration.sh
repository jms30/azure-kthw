#!/usr/bin/env bash

##################################### PARAMETERS #############################################

KUBERNETES_PUBLIC_ADDRESS=8.8.8.8               ###ADD IP ADDRESS OF YOUR AZURE LOAD BALANCER HERE 
WORKER_HOSTNAMES=(worker-1 worker-2 worker-3)
CLUSTER_NAME="kubernetes-the-hard-way"

###################################################################################################


#################################################### WORKER KUBELET CONFIG  #######################################

for instance in ${WORKER_HOSTNAMES[@]}; do
  /usr/local/bin/kubectl config set-cluster $CLUSTER_NAME \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  /usr/local/bin/kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  /usr/local/bin/kubectl config set-context default \
    --cluster=$CLUSTER_NAME \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  /usr/local/bin/kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done

#################################################################################################################



#################################################  KUBE PROXY KUBECONFIG  ##############################################

/usr/local/bin/kubectl config set-cluster $CLUSTER_NAME \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=kube-proxy.kubeconfig
/usr/local/bin/kubectl config set-credentials kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
/usr/local/bin/kubectl config set-context default \
  --cluster=$CLUSTER_NAME \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
/usr/local/bin/kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig


#################################################################################################################



################################################# KUBE CONTROLLER MANAGER  ##########################################

/usr/local/bin/kubectl config set-cluster $CLUSTER_NAME \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

/usr/local/bin/kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

/usr/local/bin/kubectl config set-context default \
    --cluster=$CLUSTER_NAME \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

/usr/local/bin/kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig


#################################################################################################################


#################################### KUBE SCHEDULER KUBECONFIG ######################################################

/usr/local/bin/kubectl config set-cluster $CLUSTER_NAME \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

/usr/local/bin/kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

/usr/local/bin/kubectl config set-context default \
    --cluster=$CLUSTER_NAME \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

/usr/local/bin/kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig

#################################################################################################################



###################################  KUBE ADMIN KUBECONFIG ###############################################################

/usr/local/bin/kubectl config set-cluster $CLUSTER_NAME \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

/usr/local/bin/kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

/usr/local/bin/kubectl config set-context default \
    --cluster=$CLUSTER_NAME \
    --user=admin \
    --kubeconfig=admin.kubeconfig

/usr/local/bin/kubectl config use-context default --kubeconfig=admin.kubeconfig

#################################################################################################################

