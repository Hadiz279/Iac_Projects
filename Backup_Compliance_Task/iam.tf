resource "aws_iam_role" "backup_service_role" {
    name =  "backup_service role"
    description = "role to enforce backup"

    assume_policy_role = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Effect = "Allow",
            Action = "sts:AssumeRole",
            Principal = {service = "backup.amazonaws.com"}
        }]
    })
}

resource "aws_iam_policy_attachment" "backup_role_attach" {
    role = aws_iam_role.backup_service_role.name
    arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_policy_document" "enforcer_policy_doc" {
    statement = {
        sid = "EC2DescribeAndTag"
        effect = "Allow"
        actions = [
            "ec2:DescribeInstances",
            "ec2:DescribeTags",
            "ec2:CreateTags",
            "ec2:DescribeVolumes",
            "ec2:CreateVolume",
            "ec2:AttachVolume",
            "ec2:DescribeSnapshots",
            "ec2:DescribeImages"
        ]
        resources = "*"
    }

    statement = {
        sid = "RDSDescribeAndTag"
        effect = "Allow"
        actions = [
            "rds:DescribeDBInstances",
            "rds:AddTagsToResource",
            "rds:DescribeDBSnapshots",
            "rds:ListTagsForResource"
        ]
        resources = "*"
    }

    statement {
    sid = "BackupReadWrite"
    effect = "Allow"
    actions = [
      "backup:ListProtectedResources",
      "backup:StartBackupJob",
      "backup:ListBackupVaults",
      "backup:GetBackupPlan",
      "backup:CreateBackupSelection",
      "backup:DeleteBackupSelection",
      "backup:TagResource",
      "backup:ListBackupSelections",
      "backup:ListBackupPlans"
    ]
    resources = ["*"]
  }

  statement {
    sid = "IAMPassRoleIfNeeded"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "enforcer_policy" {
  name   = "aws-backup-enforcer-policy"
  policy = data.aws_iam_policy_document.enforcer_policy_doc.json
}