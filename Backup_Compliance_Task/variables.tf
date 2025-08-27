var "region" {
    description = "aws region"
    type = string
    default = "us-east-1"
}

var "backup_tag_key" {
    type = string
    default = "backup"
}

var "backup_tag_value" {
    type = string
    default = "auto"
}

var "retention_days" {
    type = number
    default = 1
}

var "backup_vault_name" {
    type = string
    default = "backup_vault"
}

var "backup_plan_name" {
    type = string
    default = "backup_compliance_plan"
}