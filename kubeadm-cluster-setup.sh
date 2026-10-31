cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward=1
EOF

#Apply sysctl params without reboot

sudo sysctl --system

#verify that net.ipv4.ip_forward is set to 1 with:
sysctl net.ipv4.ip_forward


sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

# To see the new version labels
sudo apt-cache madison kubeadm

sudo apt-get install -y kubelet=1.35.0-1.1 kubeadm=1.35.0-1.1 kubectl=1.35.0-1.1

sudo apt-mark hold kubelet kubeadm kubectl

## Sping up cluster

IP_ADDR=$(ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address $IP_ADDR --pod-network-cidr=172.17.0.0/16 --service-cidr=172.20.0.0/16

## Setup kubeconfig

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

## Create join token

kubeadm token create --print-join-command
kubeadm join 192.168.9.95:6443 --token ag7ei8.n0afe8vwgnredqqq --discovery-token-ca-cert-hash sha256:70a59cdbfc5f5a3f0d49ca90198525870da1fe6f02def53d80a2c00fcc4bde72

kubeadm join 10.244.253.135:6443 --token zz5nzs.c4ywnr2gd2xc3eza --discovery-token-ca-cert-hash sha256:8734af36733528c5214f24a9eb08d939a66ed363fe00f0d6558ca9d3f1b7b4e3

## On the controlplane node, run the following set of commands to deploy the network plugin

curl -LO https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml

## Edit file and add following changes

net-conf.json: |
    {
      "Network": "10.244.0.0/16", # Update this to match the custom PodCIDR
      "Backend": {
        "Type": "vxlan"
      }

  args:
  - --ip-masq
  - --kube-subnet-mgr
  - --iface=eth0

kubectl apply -f kube-flannel.yml

## Watch pods
watch kubectl get pods -A

kubectl get nodes