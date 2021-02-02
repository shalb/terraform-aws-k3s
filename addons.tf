resource "null_resource" "wait_cluster_ready" {
  provisioner "local-exec" {
    # command = "until (curl --connect-timeout 2 https://${local.cluster_domain}:6443/ping --insecure) >/dev/null 2>&1; do sleep 1; echo waiting for k3s; done"
    command = "until (aws s3 cp s3://${var.s3_bucket}/${var.cluster_name}/${local.kubeconfig_filename} ./kubeconfig_tmp && for i in $(seq 10); do kubectl version --kubeconfig ./kubeconfig_tmp --request-timeout=5s || exit 1; sleep 1; done) >/dev/null 2>&1; do sleep 1; echo waiting for kubeconfig; done"
  }
  depends_on = [
    aws_autoscaling_group.master,
    aws_autoscaling_group.worker
  ]
}

# Not really secure as it will keep entire file as a plain text in tfstate
data "aws_s3_bucket_object" "get_kubeconfig" {
  key    = "${var.cluster_name}/${local.kubeconfig_filename}"
  bucket = var.s3_bucket
  depends_on = [
    null_resource.wait_cluster_ready
  ]
}

resource "local_file" "foo" {
  content  = "${data.aws_s3_bucket_object.get_kubeconfig.body}"
  filename = var.kubeconfig_filename
}
