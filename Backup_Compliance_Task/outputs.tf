output "backup_vault_name" {
  value = aws_backup_vault.default.name
}

output "backup_plan_id" {
  value = aws_backup_plan.daily.id
}

output "backup_service_role_arn" {
  value = aws_iam_role.backup_service_role.arn
}

output "enforcer_policy_arn" {
  value = aws_iam_policy.enforcer_policy.arn
}
