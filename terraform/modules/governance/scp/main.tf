data "aws_iam_policy_document" "require_costcenter_tag" {
  statement {
    sid       = "RequireCostCenterTagForEC2"
    effect    = "Deny"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test     = "Null"
      variable = "aws:RequestTag/CostCenter"
      values   = ["true"]
    }
  }
}

resource "aws_organizations_policy" "require_costcenter_tag" {
  name        = "require-costcenter-tag"
  description = "Deny EC2 instance launch if CostCenter tag is missing"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.require_costcenter_tag.json
}

data "aws_caller_identity" "current" {}

resource "aws_organizations_policy_attachment" "target_account" {
  policy_id = aws_organizations_policy.require_costcenter_tag.id
  target_id = data.aws_caller_identity.current.account_id
}
