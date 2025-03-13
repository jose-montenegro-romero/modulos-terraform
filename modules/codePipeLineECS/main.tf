resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-pipeline-${var.layer}-${var.stack_id}"
  acl    = "private"

  force_destroy = true

  tags = {
    Name        = "bucket-pipeline_${var.layer}_${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "role_codepipeline_${var.layer}-${var.stack_id}"

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

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "pipeline_task_execution_role_6" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "pipeline_task_execution_role_7" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "pipeline_task_execution_role_8" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_codebuild_project" "codebuild" {
  name                   = "codebuild-${var.layer}-${var.stack_id}"
  description            = "codebuild-${var.layer}-${var.stack_id}"
  build_timeout          = "60"
  queued_timeout         = "480"
  concurrent_build_limit = "1"
  service_role           = aws_iam_role.codepipeline_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/docker:18.09.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    dynamic "environment_variable" {

      for_each = length(try(var.environment_variable, "environment_variable", [])) != 0 ? var.environment_variable : []

      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }

    }

    environment_variable {
      name  = "environment"
      value = var.stack_id
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "ENVIRONMENT_NAME"
      value = var.stack_id
    }

    environment_variable {
      name  = "REPOSITORY_NAME"
      value = var.repository_name
    }

    environment_variable {
      name  = "REPOSITORY_URL"
      value = var.repository_url
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = var.container_name
    }
  }

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 0
  }

  vpc_config {
    vpc_id             = var.vpc
    subnets            = var.db_subnets_private
    security_group_ids = var.security_group_ids
  }

  tags = {
    Name        = "codebuild-pipeline_${var.layer}_${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_codebuild_project" "codebuild_automation" {

  count = var.enabled_automation == true ? 1 : 0

  name                   = "codebuild-automation-${var.layer}-${var.stack_id}"
  description            = "codebuild-automation-${var.layer}-${var.stack_id}"
  build_timeout          = "300"
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

      for_each = length(try(var.environment_variable, "environment_variable", [])) != 0 ? var.environment_variable : []

      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }

    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-automation.yml"
  }

  vpc_config {
    vpc_id             = var.vpc
    subnets            = var.db_subnets_private
    security_group_ids = var.security_group_ids
  }

  tags = {
    Name        = "codebuild-pipeline_automation_${var.layer}_${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "codepipeline-${var.layer}-${var.stack_id}"
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
        FullRepositoryId = var.repository_name
        BranchName       = var.repository_branch_names
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

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      run_order       = "1"
      input_artifacts = ["Build"]

      configuration = {
        ClusterName = var.cluster_name
        ServiceName = var.service_name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  dynamic "stage" {

    for_each = var.enabled_automation == true ? [0] : []

    content {
      name = "Automation"

      action {
        name             = "Automation"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        version          = "1"
        run_order        = "1"
        input_artifacts  = ["Source"]
        output_artifacts = ["Automation"]

        configuration = {
          ProjectName = aws_codebuild_project.codebuild_automation[0].name
        }
      }
    }

  }

  tags = {
    Name        = "codepipeline_${var.layer}_${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }
}
