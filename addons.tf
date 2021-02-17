locals {
  cloud_controller_addons_md5 = flatten([
    for file in fileset(path.module, "addons/cloud-controller/**") : [
      md5(file("${path.module}/${file}"))
    ]
  ])
}

resource "null_resource" "cloud_controller_addon_install" {
  triggers = {
    md5 = join(" ", local.cloud_controller_addons_md5)
  }
  provisioner "local-exec" {
    command     = "kubectl apply --kubeconfig ${var.kubeconfig_filename} -R -f ${path.module}/addons/cloud-controller/"
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [
    local_file.kubeconfig
  ]
}