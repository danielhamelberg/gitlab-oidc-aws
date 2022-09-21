provider "aws" {
  region = var.aws_region
}

data "tls_certificate" "gitlab" {
  url = var.gitlab_url
}

resource "aws_iam_openid_connect_provider" "gitlab" {
  url             = var.gitlab_url
  client_id_list  = [var.aud_value]
  thumbprint_list = ["${data.tls_certificate.gitlab.certificates.0.sha1_fingerprint}"]
}

data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.gitlab.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.gitlab.url}:${var.match_field}"
      values   = var.match_value
    }
  }
}

resource "aws_iam_role" "gitlab_ci" {
  name_prefix         = "GitLabCI"
  assume_role_policy  = data.aws_iam_policy_document.assume-role-policy.json
  managed_policy_arns = var.assume_role_arn
}

output "ROLE_ARN" {
  description = "Role that needs to be assumed by GitLab CI"
  value       = aws_iam_role.gitlab_ci.arn
}

output "ROLE_SESSION_NAME" {
  description = "Role session name that needs to be used by GitLab CI"
  value       = "GitLabCI"
}

output "ROLE_PROVIDER_URL" {
  description = "OpenID Connect Provider URL that needs to be used by GitLab CI"
  value       = aws_iam_openid_connect_provider.gitlab.url
}

output "ROLE_PROVIDER_ARN" {
  description = "OpenID Connect Provider ARN that needs to be used by GitLab CI"
  value       = aws_iam_openid_connect_provider.gitlab.arn
}

output "ROLE_PROVIDER_CLIENT_ID" {
  description = "OpenID Connect Provider Client ID that needs to be used by GitLab CI"
  value       = var.aud_value
}

output "ROLE_PROVIDER_THUMBPRINT" {
  description = "OpenID Connect Provider Thumbprint that needs to be used by GitLab CI"
  value       = data.tls_certificate.gitlab.certificates.0.sha1_fingerprint
}

output "ROLE_PROVIDER_MATCH_FIELD" {
  description = "OpenID Connect Provider Match Field that needs to be used by GitLab CI"
  value       = var.match_field
}

output "ROLE_PROVIDER_MATCH_VALUE" {
  description = "OpenID Connect Provider Match Value that needs to be used by GitLab CI"
  value       = var.match_value
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| assume_role_arn | List of ARNs of the IAM managed policies to attach to the role | list | `<list>` | no |
| aud_value | OpenID Connect Provider Client ID | string | - | yes |
| aws_region | AWS region | string | - | yes |
| gitlab_url | GitLab URL | string | - | yes |
| match_field | OpenID Connect Provider Match Field | string | `"aud"` | no |
| match_value | OpenID Connect Provider Match Value | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| ROLE_ARN | Role that needs to be assumed by GitLab CI |
| ROLE_PROVIDER_ARN | OpenID Connect Provider ARN that needs to be used by GitLab CI |
| ROLE_PROVIDER_CLIENT_ID | OpenID Connect Provider Client ID that needs to be used by GitLab CI |
| ROLE_PROVIDER_MATCH_FIELD | OpenID Connect Provider Match Field that needs to be used by GitLab CI |
| ROLE_PROVIDER_MATCH_VALUE | OpenID Connect Provider Match Value that needs to be used by GitLab CI |
| ROLE_PROVIDER_THUMBPRINT | OpenID Connect Provider Thumbprint that needs to be used by GitLab CI |
| ROLE_PROVIDER_URL | OpenID Connect Provider URL that needs to be used by GitLab CI |
| ROLE_SESSION_NAME | Role session name that needs to be used by GitLab CI |
