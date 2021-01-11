output "k8s_nlb_dns_name" {
  value = aws_lb.kubeapi.dns_name
}

output "kubeconfig" {
  value = data.aws_s3_bucket_object.get_kubeconfig.body
}
