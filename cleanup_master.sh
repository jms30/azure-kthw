echo -e "Stopping services"
sudo systemctl stop etcd kube-controller-manager kube-apiserver kube-scheduler

echo -e "Disabling services"
sudo systemctl disable etcd kube-controller-manager kube-apiserver kube-scheduler


echo -e "Removing etcd data"
sudo rm -r -f /etc/etcd/
sudo rm -r -f /var/lib/etcd/
sudo rm -r -f /usr/local/bin/etcd
sudo rm -r -f /usr/local/bin/etcdctl
sudo rm -r -f /etc/systemd/system/etcd.service 


echo -e "Removing kube* data"
sudo rm -r -f /etc/systemd/system/kube-controller-manager.service
sudo rm -r -f /etc/systemd/system/kube-scheduler.service
sudo rm -r -f /etc/systemd/system/kube-apiserver.service
sudo rm -r -f /etc/kubernetes
sudo rm -r -f /var/lib/kubernetes
sudo rm -r -f /usr/libexec/kubernetes
sudo rm -r -f /usr/libexec/kubernetes/kubelet-plugins
sudo rm -r -f /usr/local/bin/kube-apiserver
sudo rm -r -f /usr/local/bin/kube-controller-manager
sudo rm -r -f /usr/local/bin/kube-scheduler

echo -e "Cleaned Up Master -> Done"
