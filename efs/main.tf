resource "aws_security_group" "security_group" {
  name        = "efs_sg_${lookup(var.configuration_efs, "creation_token")}_${var.project}_${var.environment}"
  vpc_id      = var.vpc
  description = "Enable access to EFS ${lookup(var.configuration_efs, "creation_token")}"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "efs_sg_${lookup(var.configuration_efs, "creation_token")}_${var.project}_${var.environment}"
    Environment = var.environment
    Source      = "Terraform"
  }
}

resource "aws_efs_file_system" "efs_file_system" {

  availability_zone_name = lookup(var.configuration_efs, "availability_zone_name", null)
  creation_token         = "${lookup(var.configuration_efs, "creation_token")}_${var.project}_${var.environment}"
  encrypted              = lookup(var.configuration_efs, "encrypted", false)
  kms_key_id             = lookup(var.configuration_efs, "kms_key_id", null)

  dynamic "lifecycle_policy" {
    for_each = lookup(var.configuration_efs, "lifecycle_policy", null) != null ? [0] : []
    content {
      transition_to_ia                    = lookup(var.configuration_efs.lifecycle_policy, "transition_to_ia", null)
      transition_to_primary_storage_class = lookup(var.configuration_efs.lifecycle_policy, "transition_to_primary_storage_class", null)
    }
  }

  performance_mode                = lookup(var.configuration_efs, "performance_mode", "generalPurpose")
  provisioned_throughput_in_mibps = lookup(var.configuration_efs, "provisioned_throughput_in_mibps", null)
  throughput_mode                 = lookup(var.configuration_efs, "throughput_mode", null)

  tags = {
    Name        = "${lookup(var.configuration_efs, "creation_token")}_${var.project}_${var.environment}"
    Environment = var.environment
    Source      = "Terraform"
  }
}

resource "aws_efs_mount_target" "efs-mt" {
  count          = length(var.db_subnets)
  file_system_id = aws_efs_file_system.efs_file_system.id
  subnet_id      = var.db_subnets[count.index]
  # ip_address 
  security_groups = [aws_security_group.security_group.id]
}

resource "aws_efs_access_point" "efs_access_point" {

  count = length(keys(lookup(var.configuration_efs, "efs_access_point", {}))) == 0 ? 0 : 1

  file_system_id = aws_efs_file_system.efs_file_system.id

  dynamic "posix_user" {

    for_each = length(keys(lookup(var.configuration_efs.efs_access_point, "posix_user", {}))) == 0 ? [] : [0]

    content {
      gid            = lookup(var.configuration_efs.efs_access_point.posix_user, "gid", null)
      secondary_gids = lookup(var.configuration_efs.efs_access_point.posix_user, "secondary_gids", null)
      uid            = lookup(var.configuration_efs.efs_access_point.posix_user, "uid", null)
    }

  }
  dynamic "root_directory" {

    for_each = length(keys(lookup(var.configuration_efs.efs_access_point, "root_directory", {}))) == 0 ? [] : [0]

    content {
      path = lookup(var.configuration_efs.efs_access_point.root_directory, "path", null)
      dynamic "creation_info" {

        for_each = length(keys(lookup(var.configuration_efs.efs_access_point.root_directory, "creation_info", {}))) == 0 ? [] : [0]

        content {
          owner_gid   = lookup(var.configuration_efs.efs_access_point.root_directory.creation_info, "owner_gid", null)
          owner_uid   = lookup(var.configuration_efs.efs_access_point.root_directory.creation_info, "owner_uid", null)
          permissions = lookup(var.configuration_efs.efs_access_point.root_directory.creation_info, "permissions", null)
        }

      }
    }

  }

  tags = {
    Name        = "efs_access_point_${lookup(var.configuration_efs, "creation_token")}_${var.project}_${var.environment}"
    Environment = var.environment
    Source      = "Terraform"
  }
}

resource "aws_efs_backup_policy" "efs_backup_policy" {

  count          = lookup(var.configuration_efs, "backup", false) == true ? 1 : 0
  file_system_id = aws_efs_file_system.efs_file_system.id

  backup_policy {
    status = "ENABLED"
  }
}

# resource "aws_efs_file_system" "efs_file_system" {}

# resource "aws_efs_replication_configuration" "example" {
#   source_file_system_id = aws_efs_file_system.efs_file_system.id

#   destination {
#     availability_zone_name = "us-west-2b"
#     kms_key_id             = "1234abcd-12ab-34cd-56ef-1234567890ab"
#   }
# }

# resource "aws_efs_file_system_policy" "efs_file_system_policy" {
#   file_system_id = aws_efs_file_system.efs_file_system.id

#   bypass_policy_lockout_safety_check = true

#   #   policy = <<POLICY
#   # {
#   #     "Version": "2012-10-17",
#   #     "Id": "ExamplePolicy01",
#   #     "Statement": [
#   #         {
#   #             "Sid": "ExampleStatement01",
#   #             "Effect": "Allow",
#   #             "Principal": {
#   #                 "AWS": "*"
#   #             },
#   #             "Resource": "${aws_efs_file_system.fs.arn}",
#   #             "Action": [
#   #                 "elasticfilesystem:ClientMount",
#   #                 "elasticfilesystem:ClientWrite"
#   #             ],
#   #             "Condition": {
#   #                 "Bool": {
#   #                     "aws:SecureTransport": "true"
#   #                 }
#   #             }
#   #         }
#   #     ]
#   # }
#   # POLICY
# }


# https://github.com/telia-oss/terraform-aws-ecs-fargate/blob/master/examples/basic/main.tf
