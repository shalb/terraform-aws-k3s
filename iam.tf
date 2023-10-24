resource "random_pet" "iam" {}

########### masters #############
resource "aws_iam_instance_profile" "master_profile" {
  name = substr("${local.name}-master-${random_pet.iam.id}", 0, 32)
  role = aws_iam_role.master_role.name
}

resource "aws_iam_role" "master_role" {
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

resource "aws_iam_policy" "master_default_policy" {
  name   = substr("${local.name}-master-${random_pet.iam.id}", 0, 32)
  policy = file("${path.module}/policies/master.json")
}

resource "aws_iam_policy_attachment" "master-attach-default" {
  name       = substr("${local.name}-master-${random_pet.iam.id}", 0, 32)
  roles      = [aws_iam_role.master_role.name]
  policy_arn = aws_iam_policy.master_default_policy.arn
}

resource "aws_iam_policy_attachment" "master-attach" {
  for_each   = toset(var.master_iam_policies)
  name       = substr("${local.name}-master-${random_pet.iam.id}", 0, 32)
  roles      = [aws_iam_role.master_role.name]
  policy_arn = each.value
}

########### workers ############

resource "aws_iam_instance_profile" "worker_profile" {
  name = substr("${local.name}-worker-${random_pet.iam.id}", 0, 32)
  role = aws_iam_role.worker_role.name
}

resource "aws_iam_policy" "worker_default_policy" {
  name   = substr("${local.name}-worker-${random_pet.iam.id}", 0, 32)
  policy = local.worker_iam_policy_default
}

resource "aws_iam_role" "worker_role" {
  name = substr("${local.name}-worker-${random_pet.iam.id}", 0, 32)
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

resource "aws_iam_policy_attachment" "worker-attach-default" {
  name       = substr("${local.name}-worker-${random_pet.iam.id}", 0, 32)
  roles      = [aws_iam_role.worker_role.name]
  policy_arn = aws_iam_policy.worker_default_policy.arn
}

resource "aws_iam_policy_attachment" "worker-attach-global" {
  for_each   = toset(var.worker_iam_policies)
  name       = substr("${local.name}-worker-${random_pet.iam.id}", 0, 32)
  roles      = [aws_iam_role.worker_role.name]
  policy_arn = each.value
}
