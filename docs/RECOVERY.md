# Disaster Recovery

## New cluster deployment timings

```
Terraform apply (4m 40s):
    Default VPC:
        Nlb creation: 3m 10s
        ASG creation: 1m 20s
Userdata cloudinit: 40s
NLB delay: 4m 10s
All 3 master node in ready state: 5m 40s
```

## Cluster Recovery Cases

### 1. One master node reboot:
    - No recovery steps required.

### 2. One master node termination (with data lost):
    - ssh to active master node.
    - check 'kubectl get node'
    - wait when failed node change status to "NotReady"
    - drain failed node: kubectl drain NODE_NAME --force --grace-period=0 --delete-local-data --ignore-daemonsets
    - delete failed node: kubectl delete NODE_NAME
    - wait for new master node join the cluster (node will be recreated with AWS ASG)

### 3. Two master nodes reboot:
    - ssh to master0 node
    - run 'systemctl stop k3s'
    - run 'k3s server --cluster-reset'
    - run 'systemctl start k3s'
    - check cluster state 'kubectl get node'
    - if any of the nodes do not join the cluster:
        - ssh to node
        - run 'systemctl stop k3s'
        - run 'rm -rf /var/lib/rancher/k3s/server'
        - run 'systemctl start k3s'

### 4. Two master nodes termination (with data lost):
    - ssh to active node
    - run 'systemctl stop k3s'
    - run 'k3s server --cluster-reset'
    - (if active node is master0 skip this step) edit /etc/systemd/system/k3s.service
    - (if active node is master0 skip this step) remove lines with "--server https://url/" arguments
    - (if active node is master0 skip this step) run systemctl daemon-reload
    - run 'systemctl start k3s'
    - check cluster state 'kubectl get node'
    - (if active node is master0 skip this step) go to AWS console and terminate again failed instances
    - drain and delete old "NotReady" nodes (same as 2)
