CONTROLLER_PUBLIC_ADDRESS=()###ADD SPACE SEPARATED IP ADDRESS OF YOUR AZURE CONTROLLER VM

for instance in ${CONTROLLER_PUBLIC_ADDRESS[@]}; do
        echo ${instance}
        scp admin.pem admin-key.pem ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig encryption-config.yaml escrypt@${instance}:~/kubernetes_setup_files
	scp 07_etcd.sh 08_control_plane.sh cleanup_master.sh escrypt@${instance}:~/scripts
done

WORKER_PUBLIC_ADDRESS=()###ADD SPACE SEPARATED IP ADDRESS OF YOUR AZURE WORKER VM

for instance in {1..3}; do
        echo ${WORKER_PUBLIC_ADDRESS[${instance}-1]}
        scp ca.pem worker-${instance}-key.pem worker-${instance}.pem worker-${instance}.kubeconfig kube-proxy.kubeconfig escrypt@${WORKER_PUBLIC_ADDRESS[${instance}-1]}:~/kubernetes_setup_files
	scp 09_worker.sh cleanup_worker.sh escrypt@${WORKER_PUBLIC_ADDRESS[${instance}-1]}:~/scripts
done


