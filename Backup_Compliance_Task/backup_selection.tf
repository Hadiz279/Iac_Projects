resource "aws_backup_selection" "auto_tagged" {
    name = "select_tagged_resources"
    iam_role_arn = aws_iam_role.backup_service_role.arn
    plan_id = aws_backup_plan.daily.id

    selection_tag {
    type  = "STRINGEQUALS"
    key   = var.backup_tag_key
    value = var.backup_tag_value
  }
}