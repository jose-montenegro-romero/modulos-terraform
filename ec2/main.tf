module "sg" {
  source = "../sg"


  layer    = var.layer
  stack_id = var.stack_id
  // configuration sg
  name    = "ec2-${var.name}"
  vpc_id  = var.vpc
  ingress = var.ingress
  egress  = var.egress
  // TAGS
  tags = var.tags
}

resource "aws_key_pair" "key_pair" {

  key_name   = "key-ec2-${var.name}-${var.layer}-${var.stack_id}"
  public_key = file(var.public_key)
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

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:instance/*"]

    }
  }
}

# ECS intance execution role
resource "aws_iam_role" "logs_iam_execution_role" {
  name               = "iam_role_${var.name}_${var.layer}_${var.stack_id}"
  assume_role_policy = data.aws_iam_policy_document.logs_execution_role.json
}

resource "aws_iam_role_policy_attachment" "logs_policy_attachment" {
  role       = aws_iam_role.logs_iam_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.logs_iam_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "secretmanager_policy_attachment" {
  role       = aws_iam_role.logs_iam_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.logs_iam_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "logs_profile" {
  name = "profile_${var.name}_${var.layer}_${var.stack_id}"
  role = aws_iam_role.logs_iam_execution_role.name
}

data "template_file" "script" {

  count    = var.template_file != null ? 1 : 0
  template = file(var.template_file)
  vars     = var.template_file_vars
}

resource "aws_instance" "instance" {
  ami                     = var.ami
  instance_type           = var.instance_type
  key_name                = aws_key_pair.key_pair.key_name
  subnet_id               = var.db_subnets_public[0]
  vpc_security_group_ids  = ["${module.sg.sg_reference.id}"]
  disable_api_termination = var.disable_api_termination
  iam_instance_profile    = aws_iam_instance_profile.logs_profile.name
  user_data               = var.template_file != null ? data.template_file.script[0].rendered : null

  dynamic "root_block_device" {

    for_each = length(var.root_block_device) == 0 ? [] : var.root_block_device

    content {
      delete_on_termination = root_block_device.value.delete_on_termination
      encrypted             = root_block_device.value.encrypted
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
    }
  }

  tags = merge(var.tags, {
    Name        = "ec2-${var.name}-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}

resource "aws_eip" "elastic_ip" {

  count = var.eip == true ? 1 : 0

  instance = aws_instance.instance.id

  tags = merge(var.tags, {
    Name        = "elastic-ip-${var.name}-${var.layer}-${var.stack_id}"
    Environment = var.stack_id
    Source      = "Terraform"
  })
}
