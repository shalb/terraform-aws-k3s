output "k8s_nlb_dns_name" {
  value = aws_lb.kubeapi.dns_name
}

output "kubeconfig" {
  value = data.aws_s3_object.get_kubeconfig.body
}

output "kubeconfig_s3_url" {
  value = "s3://${var.s3_bucket}/${var.cluster_name}/${local.s3_kubeconfig_filename}"
}

output "endpoint" {
  description = "The endpoint for Kubernetes API server."
  value       = local.k_config.host
}

output "certificate_authority" {
  description = "The base64 encoded certificate data required to communicate with cluster. Add this to the certificate-authority-data section of the kubeconfig file for cluster."
  value       = local.k_config.host_cert
}

output "client_certificate" {
  description = "The base64 encoded client-certificate-data required to communicate with cluster."
  value       = local.k_config.user_crt
}

output "client_key_data" {
  description = "The base64 encoded client-key-data required to communicate with cluster."
  value       = local.k_config.cert_data
}
