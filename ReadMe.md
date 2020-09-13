Follow steps from: [Official KTHW](https://github.com/kelseyhightower/kubernetes-the-hard-way/tree/master/docs) and for azure installation (strictly for reference) [forked repo from official KTHW](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/tree/master/docs)

This guide facilitates creation of Kubernetes Cluster on Azure Cloud. Please use this guide for 
(A) as reference to create your VM network with necessary configuration in Azure cloud and (B) run the commands that are provided in following shell scripts so that you do not have to Copy + Paste + Adjust the commands from Official KTHW guide on individual VM consoles.


# Requirements for Azure VMs:
1. Create 3 controller VMs and 3 worker VMs. Use VM Network ranges as **10.0.0.0/24**. The controller VMs should be of atleast 2 vCPUs and 8 GB RAM which can be achieved with type *Standard D2s v3*. The worker VMs should be atleast 2 vCPUs and 2GB RAM which can be achieved with type *Basic A2*. Make sure that you do not have overlap between VM Network Range and Service Cluster IP range (See below at step 11). 

2. All VMs should be running CentOS 7.5. Make sure all VMs have **IP forwarding** as **Enabled**.

3. For controllers: assign hostnames and IP addresses as:  *controller\-1 (10.0.0.11), controller\-2 (10.0.0.12), controller\-3 (10.0.0.13)*
4. For workers: assign hostname and IP addresses as:  *worker\-1 (10.0.0.21), worker\-2 (10.0.0.22), worker\-3 (10.0.0.23)*

5. All VMs should have firewall service disabled. To do so, run following command on each VM. 
   
   *sudo systemctl stop firewalld.service*

6. We do not want any interference from  SE Linux security permissions. To disable the flag, set **SELINUX=permissive** in file */etc/selinux/config*. You might need to update it with root. Reboot your devices at this stage.

7. Create an Azure Load Balancer. Add your controller VMs as Backend pool. 

8. When creating VMs, make sure each VM gets explicit public IP address. You need to adapt scripts for that too. For controllers, the public IP SKU type needs to be Standard to allow Load Balancer to balance the load on this IP. 

	Scripts to adapt with approprite public IP addresses of Worker VMs are: 
	* 04_certificate.sh
	* 10_kubectl_access.sh
	* copy_files.sh

9. You need to adapt following scripts with Public IP address of your Load Balancer.

	Scripts to adapt with public IP address of Load balancer are:
	* 04_certificate.sh
	* 05_configuration.sh
	* 10_kubectl_access.sh
	
10. On each VM, create two folders in home directory as *kubernetes_setup_files* and *scripts*.

11. Following are the defined IP ranges for different purposes.
	* Service Cluster IP range: **10.32.0.0/24**
	* DNS service IP: **10.32.0.10**
	* Cluster CIDR (Pod Network Range): **192.168.0.0/16**
	* Per worker, we further divide the pod network range so that each worker is responsible for tightened subnet to assign to pods running on it self. They are **192.168.1.0/24, 192.168.2.0/24** and **192.168.3.0/24**

***Make sure that you have ssh accessibility from local machine to all VMs in cloud.*** 

## You need to run following scripts on controllers

* 07_etcd.sh
* 08_control_plane.sh
* 08_control_plane_rbac.sh
* 10_kubectl_access.sh

## You need to run following scripts on workers

* 09_worker.sh

## You need to run following scripts on local machine and then copy the generated data to controllers and workers. 

* 04_certificate.sh
* 05_configuration.sh
* 06_encryption.sh
* 10_kubectl_access.sh
* copy_files.sh

At any point, if you feel that you want to completely tear down your controller and workers, feel free to run **cleanup_master.sh** and **cleanup_worker.sh** scripts on controller and worker respectively.

# Choice of CNI (Step 11)

On Azure, you cannot use Calico CNI straight out of the box. To use Calico, you need to install Azure CNI plugin. More infomration can be found [here](https://docs.projectcalico.org/reference/public-cloud/azure)

If you want to use Cilium as CNI, you need to take care of a few things. 
1. **Firewall**: You need to enable firewall on all devices so that Cilium can add Iptable rules. For easiness, simple add following rules on firewall on each device

	*sudo systemctl firewall-cmd --permanent --zone=public --add-source={your VM network range and subnet mask}*

	*sudo systemctl firewall-cmd --add-port 2379/tcp --permanent*

	*sudo systemctl firewall-cmd --add-port 2380/tcp --permanent*

	*sudo systemctl firewall-cmd --add-port 6443/tcp --permanent*

	*sudo systemctl firewall-cmd --add-port 10250/tcp --permanent*

	*sudo systemctl firewall-cmd --add-port 8472/udp --permanent*

	*sudo systemctl firewall-cmd --add-port 4240/tcp --permanent*

	*sudo systemctl firewall-cmd --reload*

2. **Linux kernel version**: Cilium uses eBPF technology which is supported from kernel >= 4.8.0. Follow [this guide](https://phoenixnap.com/kb/how-to-upgrade-kernel-centos) to update your kernel version.

To install Cilium, just apply following command on one of the controllers:

*kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.7/install/kubernetes/quick-install.yaml*

# Step 12- DNS add on:
You might need to create a symbolic link in order to have your *core-dns* pod running successfully. To do so, go on all your workers and run following commands.

*sudo mkdir -p /run/systemd/resolve*

*sudo ln -s /etc/resolv.conf /run/systemd/resolve/resolv.conf*