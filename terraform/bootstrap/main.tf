data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_org}/${var.github_repo}:*"
      ]
    }
  }
}


resource "aws_iam_role" "terraform_automation" {
  name = "${var.project_name}-${var.environment}-terraform-automation"

  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json

  tags = {
    Name = "${var.project_name}-${var.environment}-terraform-automation"
  }
}


data "aws_iam_policy_document" "terraform_automation" {
  statement {
    sid = "ManageProjectInfrastructure"

    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
      "cloudwatch:*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "ReadTerraformStateBucket"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning"
    ]

    resources = [
      aws_s3_bucket.terraform_state.arn
    ]
  }

  statement {
    sid = "ManageTerraformStateObjects"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.terraform_state.arn}/project1/dev/*"
    ]
  }
}

resource "aws_iam_role_policy" "terraform_automation" {
  name = "${var.project_name}-${var.environment}-terraform-automation-policy"
  role = aws_iam_role.terraform_automation.id

  policy = data.aws_iam_policy_document.terraform_automation.json
}
