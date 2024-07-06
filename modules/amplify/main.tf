// amplify用のbasic認証
locals {
  amplify_auth = base64encode("${var.amplify_username}:${var.amplify_password}")
}

resource "aws_iam_role" "amplify_role" {
  name               = "AmplifyServiceRoleForCWL-${var.project_name}-${var.infra_environment}-front"
  assume_role_policy = data.aws_iam_policy_document.amplify_assume_role.json
  managed_policy_arns = [
    aws_iam_policy.amplify_policy.arn
  ]
  tags = {
    Environment = var.infra_environment
    Project     = var.project_name
  }
}

data "aws_iam_policy_document" "amplify_assume_role" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "amplify_policy" {
  name   = "AmplifyAccessForCWL-${var.project_name}-${var.infra_environment}-front"
  policy = data.aws_iam_policy_document.amplify_policy_document.json
}

data "aws_iam_policy_document" "amplify_policy_document" {
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:PutLogEvents"
    ]
  }
}

resource "aws_amplify_app" "frontend" {
  name                   = "AmplifyFrontend-${var.project_name}-${var.infra_environment}"
  repository             = "https://github.com/${var.github_repository_front}"
  enable_basic_auth      = true
  basic_auth_credentials = local.amplify_auth
  access_token           = var.github_access_token
  build_spec             = <<-EOT
    version: 1
    applications:
      - appRoot: application
        frontend:
          phases:
            preBuild:
              commands:
                - curl https://get.volta.sh | bash
                - source ~/.bash_profile
                - volta install node
                - npm ci
            build:
              commands:
                - npm run build
          artifacts:
            baseDirectory: .next
            files:
              - "**/*"
          cache:
            paths:
              - "node_modules/**/*"
  EOT

  platform             = "WEB_COMPUTE"
  iam_service_role_arn = aws_iam_role.amplify_role.arn
  environment_variables = {
    NEXT_PUBLIC_API_BASE_URL     = "https://api.${var.domain}"
    NEXT_PUBLIC_CREDENTIALS      = "include"
    _DISABLE_L2_CACHE            = true
    NEXT_PUBLIC_AUTH_KEY         = var.alb_auth_header_name
    NEXT_PUBLIC_AUTH_VALUE       = var.alb_auth_header_password
    AMPLIFY_MONOREPO_APP_ROOT    = "application"
    NEXT_PUBLIC_MAINTENANCE_MODE = false
  }
  tags = {
    Environment = var.infra_environment
    Project     = var.project_name
  }
}

resource "aws_amplify_branch" "develop" {
  app_id              = aws_amplify_app.frontend.id
  branch_name         = var.github_branch_front
  enable_auto_build   = !var.is_prd
  framework           = "Next.js - SSR"
  stage               = var.github_branch_front == "main" ? "PRODUCTION" : "DEVELOPMENT"
  enable_notification = true
}

resource "aws_cloudwatch_event_rule" "amplify_app_branch" {
  name = "${var.project_name}-${var.infra_environment}-front-pipeline"
  event_pattern = jsonencode({
    "detail" = {
      "appId"      = [aws_amplify_app.frontend.id]
      "branchName" = [aws_amplify_branch.develop.branch_name],
      "jobStatus" = [
        "SUCCEED",
        "FAILED"
      ]
    }
    "detail-type" = ["Amplify Deployment Status"]
    "source"      = ["aws.amplify"]
  })
}

resource "aws_cloudwatch_event_target" "amplify_app_branch" {
  rule      = aws_cloudwatch_event_rule.amplify_app_branch.name
  target_id = aws_amplify_branch.develop.branch_name
  arn       = var.cicd_topic_arn
  input_transformer {
    input_paths = {
      jobId  = "$.detail.jobId"
      appId  = "$.detail.appId"
      region = "$.region"
      branch = "$.detail.branchName"
      status = "$.detail.jobStatus"
    }

    input_template = "\"Build notification from the AWS Amplify Console for app: https://<branch>.<appId>.amplifyapp.com/. Your build status is <status>. Go to https://console.aws.amazon.com/amplify/home?region=<region>#<appId>/<branch>/<jobId> to view details on your build. \""
  }
}
