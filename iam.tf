/*
  Controllers
*/

resource "aws_iam_role" "controller" {
  name = "${local.name}-controller"
  path = "/"

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

resource "aws_iam_instance_profile" "controller" {
  name = "${local.name}-controller"
  role = aws_iam_role.controller.name
}

resource "aws_iam_policy" "controller_policy" {
  name   = "${local.name}-controller"
  policy = file("${path.module}/policies/controller.json")
}

resource "aws_iam_policy_attachment" "controller" {
  name       = "${local.name}-controller"
  roles      = [aws_iam_role.controller.name]
  policy_arn = aws_iam_policy.controller_policy.arn
}

resource "aws_iam_policy" "controller_ecr" {
  name   = "${local.name}-controller-ecr"
  policy = file("${path.module}/policies/ecr.json")
}

resource "aws_iam_policy_attachment" "controller_ecr" {
  name       = "${local.name}-controller-ecr"
  roles      = [aws_iam_role.controller.name]
  policy_arn = aws_iam_policy.controller_ecr.arn
}

resource "aws_iam_policy_attachment" "controller_ssm" {
  name       = "${local.name}-controller-ssm"
  roles      = [aws_iam_role.controller.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# resource "aws_iam_policy_attachment" "master-attach" {
#   for_each   = toset(var.master_iam_policies)
#   name       = substr("${local.name}-master-${random_pet.iam.id}", 0, 32)
#   roles      = [aws_iam_role.master_role.name]
#   policy_arn = each.value
# }

/*
  Workers
*/

resource "aws_iam_role" "worker" {
  name = "${local.name}-worker"
  path = "/"

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

resource "aws_iam_instance_profile" "worker" {
  name = "${local.name}-worker"
  role = aws_iam_role.worker.name
}

resource "aws_iam_policy" "worker" {
  name   = "${local.name}-worker"
  policy = file("${path.module}/policies/worker.json")
}

resource "aws_iam_policy_attachment" "worker" {
  name       = "${local.name}-worker"
  roles      = [aws_iam_role.worker.name]
  policy_arn = aws_iam_policy.worker.arn
}

# resource "aws_iam_policy_attachment" "worker-attach-global" {
#   for_each   = toset(var.worker_iam_policies)
#   name       = substr("${local.name}-worker-${random_pet.iam.id}", 0, 32)
#   roles      = [aws_iam_role.worker_role.name]
#   policy_arn = each.value
# }
