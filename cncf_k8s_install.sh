#!/bin/bash

set -e

sed -e '/swap/s/^/#/g' -i /etc/fstab 

swapoff -a

modprobe dm-snapshot

apt-get update && apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes &&

apt-get install nfs-common -y

apt-get install zfsutils-linux -y

apt-get update && apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update && apt-get install -y kubeadm=1.23.5-00 kubelet=1.23.5-00 kubectl=1.23.5-00 

apt-get install docker.io -y
apt-mark hold kubelet kubeadm kubectl

sed -i -e 's/containerd.sock/containerd.sock --exec-opt native.cgroupdriver=systemd/g' /lib/systemd/system/docker.service 
systemctl daemon-reload 
systemctl restart docker

if [ "$1" == "master" ]; then
export MASTER_IP=$2
kubeadm init --apiserver-advertise-address=$2 --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

else
echo "installation of k8s on nodes successfully done!"
fi

