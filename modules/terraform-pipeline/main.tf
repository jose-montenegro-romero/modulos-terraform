resource "aws_s3_bucket" "bucket" {
  bucket = "pipeline-terraform-${var.layer}-${var.stack_id}"
  acl    = "private"

  force_destroy = true

  tags = {
    Name        = "pipeline-terraform-${var.layer}"
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "role_codepipeline_terraform_${var.layer}_${var.stack_id}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["codepipeline.amazonaws.com","codebuild.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "pipeline_task_execution_role_1" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "pipeline_task_execution_role_2" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "pipeline_task_execution_role_3" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "pipeline_task_execution_role_4" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "pipeline_task_execution_role_5" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_codebuild_project" "codebuild" {
  name                   = "codebuild-terraform-${var.layer}_${var.stack_id}"
  description            = "codebuild-terraform-${var.layer}_${var.stack_id}"
  build_timeout          = "60"
  queued_timeout         = "480"
  concurrent_build_limit = "1"
  service_role           = aws_iam_role.codepipeline_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    dynamic "environment_variable" {

      for_each = length(lookup(var.configuration_codepipeline_terraform, "environment_variable", [])) != 0 ? lookup(var.configuration_codepipeline_terraform, "environment_variable") : []

      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }

    }
  }

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 0
  }

  tags = {
    Name        = "codebuild_terraform_pipeline_${var.layer}_${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "codepipeline-s3-${var.layer}-${var.stack_id}"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      run_order        = "1"
      output_artifacts = ["Source"]

      configuration = {
        ConnectionArn    = var.ConnectionArn
        FullRepositoryId = lookup(var.configuration_codepipeline_terraform, "repository_name")
        BranchName       = lookup(var.configuration_codepipeline_terraform, "repository_branch_name")
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = "1"
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }

  tags = {
    Name        = "codepipeline_terraform_${var.layer}_${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }
}
