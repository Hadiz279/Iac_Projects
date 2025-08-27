resource "aws_backup_vault" "default" {
  name = var.backup_vault_name

  tags = {
    ManagedBy = "terraform"
    Project   = "backup-compliance"
  }
}
