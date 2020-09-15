echo -e "Stopping services"
sudo systemctl stop containered kubelet kube-proxy

echo -e "Disabling services"
sudo systemctl disable containerd kubelet kube-proxy


echo -e "Removing containerd data"
sudo rm -r -f /run/containerd
sudo rm -r -f /etc/containerd
sudo rm -r -f /var/lib/containerd
sudo rm -r -f /usr/bin/containerd
sudo rm -r -f /home/escrypt/scripts/containerd
sudo rm -r -f /opt/containerd

echo -e "Removing kube* data"
sudo rm -r -f /var/lib/kube*
sudo rm -r -f /usr/libexec/kubernetes
sudo rm -r -f /usr/local/bin/kubectl
sudo rm -r -f /usr/local/bin/kube-proxy
sudo rm -r -f /usr/local/bin/kubelet

echo -e "Cleaned Up on Worker -> Done."
