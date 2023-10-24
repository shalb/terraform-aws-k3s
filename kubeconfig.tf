resource "null_resource" "wait_cluster_ready" {
  provisioner "local-exec" {
    command = "until (aws s3 cp s3://${var.s3_bucket}/${var.cluster_name}/${local.s3_kubeconfig_filename} ./kubeconfig_tmp && for i in $(seq 10); do kubectl version --kubeconfig ./kubeconfig_tmp --request-timeout=5s || exit 1; sleep 1; done) >/dev/null 2>&1; do sleep 1; echo waiting for kubeconfig; done"
  }
  depends_on = [
    aws_autoscaling_group.master,
    aws_autoscaling_group.worker,

  ]
}

# Not really secure as it will keep entire file as a plain text in tfstate
data "aws_s3_object" "get_kubeconfig" {
  key    = "${var.cluster_name}/${local.s3_kubeconfig_filename}"
  bucket = var.s3_bucket
  depends_on = [
    null_resource.wait_cluster_ready
  ]
}

locals {
  k_config = element(flatten([
    for cl in yamldecode(data.aws_s3_object.get_kubeconfig.body).clusters : [
      for u in yamldecode(data.aws_s3_object.get_kubeconfig.body).users : {
        host      = cl.cluster.server
        host_cert = base64decode(cl.cluster.certificate-authority-data)
        user_crt  = base64decode(u.user.client-certificate-data)
        cert_data = base64decode(u.user.client-key-data)
      }
    ]
  ]), 0)
}
