KUBERNETES_PUBLIC_ADDRESS=###ADD IP ADDRESS OF YOUR AZURE LOAD BALANCER HERE 

CONFIG_FILE_PATH=../kubernetes_setup_files

CWD=$(pwd)

cd ${CONFIG_FILE_PATH}


kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443
kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem
kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin
kubectl config use-context kubernetes-the-hard-way

cd ${CWD}
