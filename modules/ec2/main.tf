resource "aws_security_group" "sg_bastion" {
  name        = "ec2_sg_${lookup(var.ec2_definition, "name_ec2")}_${var.layer}_${var.stack_id}"
  vpc_id      = var.vpc
  description = "Enable access to ec2 ${lookup(var.ec2_definition, "name_ec2")}"

  dynamic "ingress" {

    for_each = lookup(var.ec2_definition, "ingress")

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {

    for_each = lookup(var.ec2_definition, "egress")

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name   = "ec2_sg_${lookup(var.ec2_definition, "name_ec2")}_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
}

resource "aws_key_pair" "key_pair" {

  count = lookup(var.ec2_definition, "public_key", null) != null ? 1 : 0

  key_name   = "key_ec2_${lookup(var.ec2_definition, "name_ec2")}_${var.layer}_${var.stack_id}"
  public_key = file(lookup(var.ec2_definition, "public_key"))
}

# EC2 policy logs
data "aws_iam_policy_document" "logs_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ECS intance execution role
resource "aws_iam_role" "logs_iam_execution_role" {
  name               = "iam_role_${lookup(var.ec2_definition, "name_ec2")}_${var.layer}_${var.stack_id}"
  assume_role_policy = data.aws_iam_policy_document.logs_execution_role.json
}

resource "aws_iam_role_policy_attachment" "logs_policy_attachment" {
  role       = aws_iam_role.logs_iam_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "instance_profile_codedeploy" {
  role       = aws_iam_role.logs_iam_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_instance_profile" "logs_profile" {
  name = "profile_${lookup(var.ec2_definition, "name_ec2")}_${var.layer}_${var.stack_id}"
  role = aws_iam_role.logs_iam_execution_role.name
}

data "template_file" "script" {

  count    = lookup(var.ec2_definition, "template_file", null) != null ? 1 : 0
  template = file(lookup(var.ec2_definition, "template_file"))
  vars     = lookup(var.ec2_definition, "vars", {})
}

resource "aws_instance" "instance" {
  ami                     = lookup(var.ec2_definition, "ami")
  instance_type           = lookup(var.ec2_definition, "instance_type")
  key_name                = lookup(var.ec2_definition, "public_key", null) != null ? aws_key_pair.key_pair[0].key_name : null
  subnet_id               = var.db_subnets_public[0]
  vpc_security_group_ids  = ["${aws_security_group.sg_bastion.id}"]
  disable_api_termination = lookup(var.ec2_definition, "disable_api_termination")
  iam_instance_profile    = aws_iam_instance_profile.logs_profile.name
  user_data               = lookup(var.ec2_definition, "template_file", null) != null ? data.template_file.script[0].rendered : null

  dynamic "root_block_device" {

    for_each = length(keys(lookup(var.ec2_definition, "root_block_device", {}))) == 0 ? [] : [0]

    content {
      delete_on_termination = lookup(var.ec2_definition.root_block_device, "delete_on_termination", true)
      encrypted             = lookup(var.ec2_definition.root_block_device, "encrypted", false)
      volume_size           = lookup(var.ec2_definition.root_block_device, "volume_size", 10)
      volume_type           = lookup(var.ec2_definition.root_block_device, "volume_type", "gp2")
    }
  }

  tags = {
    Name   = "ec2_${lookup(var.ec2_definition, "name_ec2")}_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
}

resource "aws_eip" "elastic_ip" {

  count = lookup(var.ec2_definition, "eip", null) == true ? 1 : 0

  vpc = true

  instance = aws_instance.instance.id

  tags = {
    Name   = "elastic_ip_${lookup(var.ec2_definition, "name_ec2")}_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
}
