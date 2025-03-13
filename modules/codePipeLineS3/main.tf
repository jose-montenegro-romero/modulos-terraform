resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-pipeline-s3-${var.layer}-${var.stack_id}"
  acl    = "private"

  force_destroy = true

  tags = {
    Name        = "bucket_pipeline_s3_${var.layer}_${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "role_codepipeline_s3_${var.layer}-${var.stack_id}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["codepipeline.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "codebuild_role" {
  name = "role_codebuild_s3_${var.layer}-${var.stack_id}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["codebuild.amazonaws.com"]
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
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "codebuild_task_execution_role_1" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "codebuild_task_execution_role_2" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "codebuild_task_execution_role_3" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "codebuild_task_execution_role_4" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "codebuild_task_execution_role_5" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# task execution role policy attachment
resource "aws_iam_role_policy_attachment" "codebuild_task_execution_role_6" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

resource "aws_security_group" "security_group" {
  name        = "pipeline_s3_security_group_${var.layer}_${var.stack_id}"
  description = "controls access to code pipeline s3"
  vpc_id      = var.vpc

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "pipeline_s3_${var.layer}_${var.stack_id}"
    Source = "Terraform"
  }
}

resource "aws_codebuild_project" "codebuild" {
  name                   = "codebuild-s3-${var.layer}-${var.stack_id}"
  description            = "codebuild-s3-${var.layer}-${var.stack_id}"
  build_timeout          = "60"
  queued_timeout         = "480"
  concurrent_build_limit = "1"
  service_role           = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.compute_type
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

    environment_variable {
      name  = "CLOUDFRONT_ID"
      value = var.cloudfront_id
    }
  }

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 0
  }

  vpc_config {
    vpc_id             = var.vpc
    subnets            = var.db_subnets_private
    security_group_ids = ["${aws_security_group.security_group.id}"]
  }

  tags = {
    Name        = "codebuild_s3_pipeline_${var.layer}_${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }
}

data "template_file" "buildspec" {

  count = var.enabled_clear_cache == true ? 1 : 0

  template = file(var.buildspec_cache_clear)
  vars = {
    CLOUDFRONT_ID = var.cloudfront_id
  }
}

resource "aws_codebuild_project" "codebuild_clear_cache" {

  count = var.enabled_clear_cache == true ? 1 : 0

  name                   = "codebuild-clear-cache-${var.layer}-${var.stack_id}"
  description            = "codebuild-clear-cache-${var.layer}-${var.stack_id}"
  build_timeout          = "300"
  queued_timeout         = "480"
  concurrent_build_limit = "1"
  service_role           = aws_iam_role.codebuild_role.arn

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
    buildspec = data.template_file.buildspec[0].rendered
  }

  vpc_config {
    vpc_id             = var.vpc
    subnets            = var.db_subnets_private
    security_group_ids = ["${aws_security_group.security_group.id}"]
  }

  tags = {
    Name        = "codebuild-pipeline_clear_cache_${var.layer}_${var.stack_id}"
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
      provider        = "S3"
      version         = "1"
      run_order       = "1"
      region          = var.region
      input_artifacts = ["Build"]

      // https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-S3Deploy.html
      configuration = {
        BucketName   = var.BucketName
        Extract      = "true"
        CacheControl = var.CacheControl
      }
    }
  }

  dynamic "stage" {

    for_each = var.enabled_clear_cache == true ? [0] : []

    content {
      name = "Clearcache"

      action {
        name      = "Clearcache"
        category  = "Build"
        owner     = "AWS"
        provider  = "CodeBuild"
        version   = "1"
        run_order = "1"
        input_artifacts = ["Build"]

        configuration = {
          ProjectName = aws_codebuild_project.codebuild_clear_cache[0].name
        }
      }
    }

  }

  tags = {
    Name        = "codepipeline_s3_${var.layer}_${var.stack_id}"
    environment = var.stack_id
    source      = "Terraform"
  }
}
