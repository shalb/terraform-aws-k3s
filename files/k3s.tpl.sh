#!/bin/bash

main() {
software_install
}

software_install() {
  set -x
  echo "Install additional software here..."
  curl https://releases.rancher.com/install-docker/24.0.2.sh | bash
  apt-get install -y jq wget unzip python3-pip
  pip3 install awscli

  mount bpffs -t bpf /sys/fs/bpf

  SERVER_URL="--server https://${cluster_domain}:6443"
  CLUSTER_INIT=""
  START_ARGS=""
%{ if instance_role == "master" }
  %{ if instance_index == "0" }
    if  ! nc -z -v -w1 ${cluster_domain} 6443; then
      SERVER_URL=""
      CLUSTER_INIT="--cluster-init"
    fi
  %{ endif }
  START_ARGS="server --cluster-domain ${cluster_domain} --secrets-encryption --node-name $(curl http://169.254.169.254/latest/meta-data/local-hostname) \
  --disable-cloud-controller \
  --disable servicelb \
  --kubelet-arg="cloud-provider=external" \
  --kubelet-arg="provider-id=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)" \
  "
  START_ARGS="$${START_ARGS} ${extra_args}"
%{ endif }

%{ if instance_role == "worker" }
  START_ARGS="agent --node-name $(curl http://169.254.169.254/latest/meta-data/local-hostname) \
  --kubelet-arg="cloud-provider=external" \
  --kubelet-arg="provider-id=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)" \
  "
%{ endif }

  START_ARGS="$${START_ARGS} ${node_labels} ${node_taints}"
  if [ ! -z "$${SERVER_URL}" ]; then
    until (curl --connect-timeout 2 https://${cluster_domain}:6443/ping --insecure); do
        echo 'Waiting for k3s server...'
        sleep 2
    done
  fi
  curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v${k3s_version}' sh -s - $${START_ARGS} --token ${k3s_server_token} $${SERVER_URL} $${CLUSTER_INIT}

%{ if instance_role == "master" }
  until (kubectl version); do
    sleep 60
    systemctl start k3s
  done

  %{ if instance_index == "0" }
    cp /etc/rancher/k3s/k3s.yaml /tmp/
    sed -i 's/127.0.0.1/${cluster_domain}/g' /tmp/k3s.yaml
    aws s3 cp --content-type text/plain /tmp/k3s.yaml s3://${s3_bucket}/${cluster_name}/${kubeconfig_name}
    mkdir -p /var/lib/rancher/k3s/server/db/snapshots/
    echo "15 */12 * * *       root    aws s3 sync --delete /var/lib/rancher/k3s/server/db/snapshots/ s3://${s3_bucket}/${cluster_name}/backups/" >> /etc/crontab
    echo "" >> /etc/crontab
  %{ endif }

%{ endif }
%{ if instance_role == "worker" }
  until (systemctl status k3s-agent); do
    sleep 60
    systemctl start k3s-agent
  done
%{ endif }
}

main
