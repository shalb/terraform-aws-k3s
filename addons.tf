locals {
  cloud_controller_addons_md5 = flatten([
    for file in fileset(path.module, "addons/cloud-controller/**") : [
      md5(file("${path.module}/${file}"))
    ]
  ])
  rolling_updater_addons_md5 = flatten([
    for file in fileset(path.module, "addons/rolling-update/**") : [
      md5(file("${path.module}/${file}"))
    ]
  ])
}

resource "null_resource" "cloud_controller_addon_install" {
  triggers = {
    md5 = join(" ", local.cloud_controller_addons_md5)
  }
  provisioner "local-exec" {
    command     = "kubectl apply --kubeconfig <(echo $KUBECONFIG | base64 -d) -R -f ${path.module}/addons/cloud-controller/"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(data.aws_s3_bucket_object.get_kubeconfig.body)
    }
  }
  depends_on = [
    null_resource.wait_cluster_ready
  ]
}

data "template_file" "rolling_updater" {
  count    = var.enable_asg_rolling_auto_update == true ? 1 : 0
  template = file("${path.module}/addons/rolling-update/main.yaml")
  vars = {
    asg_list = join(",", [for key, value in aws_autoscaling_group.worker :
      value.name
    ])
    aws_region = var.region
  }
  depends_on = [
    null_resource.wait_cluster_ready
  ]
}

resource "null_resource" "rolling_updater_addon_install" {
  count = var.enable_asg_rolling_auto_update == true ? 1 : 0
  triggers = {
    yaml = data.template_file.rolling_updater[0].rendered
  }
  provisioner "local-exec" {
    command     = "kubectl apply --kubeconfig <(echo $KUBECONFIG | base64 -d) -R -f -<<EOF\n${self.triggers.yaml}\nEOF"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(data.aws_s3_bucket_object.get_kubeconfig.body)
    }
  }
  depends_on = [
    null_resource.wait_cluster_ready
  ]
}
