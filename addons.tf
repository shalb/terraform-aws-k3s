resource "null_resource" "wait_cluster_ready" {
  provisioner "local-exec" {
    # command = "until (curl --connect-timeout 2 https://${local.cluster_domain}:6443/ping --insecure) >/dev/null 2>&1; do sleep 1; echo waiting for k3s; done"
    command = "until (aws s3 cp s3://${var.s3_bucket}/${var.cluster_name}/${local.kubeconfig_filename} ${var.kubeconfig_filename} && for i in $(seq 10); do kubectl version --kubeconfig ./kubeconfig --request-timeout=5s || exit 1; sleep 1; done) >/dev/null 2>&1; do sleep 1; echo waiting for kubeconfig; done"
  }
  depends_on = [
    aws_autoscaling_group.master,
    aws_autoscaling_group.worker
  ]
}
