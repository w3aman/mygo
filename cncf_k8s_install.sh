#!/bin/bash

set -e

sed -e '/swap/s/^/#/g' -i /etc/fstab 

swapoff -a

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
