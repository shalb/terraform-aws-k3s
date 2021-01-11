resource "random_pet" "iam" {}

resource "aws_iam_instance_profile" "k3s_master_profile" {
  name = substr("${local.name}-master-${random_pet.iam.id}", 0, 32)
  role = aws_iam_role.k3s_master_role.name
}

resource "aws_iam_role_policy" "k3s_master_policy" {
  name   = substr("${local.name}-master-${random_pet.iam.id}", 0, 32)
  role   = aws_iam_role.k3s_master_role.id
  policy = file("${path.module}/policies/master.json")
}

resource "aws_iam_role" "k3s_master_role" {
  name = substr("${local.name}-master-${random_pet.iam.id}", 0, 32)
  path = "/"

  depends_on = [
    null_resource.validate_domain_length
  ]
  tags               = local.common_tags
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
