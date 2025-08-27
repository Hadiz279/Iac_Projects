resource "aws_backup_plan" "daily" {
  name = var.backup_plan_name

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.default.name
    
    schedule = "cron(0 3 * * ? *)"

    lifecycle {
      delete_after = var.retention_days
    }
  }
}
