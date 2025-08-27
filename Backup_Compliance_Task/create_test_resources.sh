#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"

# 2 Small EC2 instances (t3.micro).
for i in 1 2; do
  NAME="test-ec2-unprotected-${i}"
  echo "Creating EC2 ${NAME}"
  aws ec2 run-instances \
    --image-id "$(aws ec2 describe-images --owners amazon \
      --filters 'Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2' --query 'Images|[0].ImageId' -o text || echo ami-0c02fb55956c7d316)" \
    --count 1 --instance-type t3.micro --region "$REGION" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${NAME}},{Key=Owner,Value=test}]" \
    --output json || true
done

# 2 Unattached EBS volumes (small 1GB)
for i in 1 2; do
  echo "Creating unattached EBS volume vol-test-${i}"
  aws ec2 create-volume --size 1 --availability-zone "${REGION}a" --volume-type gp2 \
    --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=vol-test-${i}}]" --region "$REGION" >/dev/null
done

#2 RDS instances with backups disabled (db.t3.micro) - set backup retention to 0 to disable
for i in 1 2; do
  DB="test-rds-no-backup-${i}"
  echo "Creating RDS MySQL ${DB} with backup retention 0 (disabled backups)"
  aws rds create-db-instance \
    --db-instance-identifier "${DB}" \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --master-username adminuser \
    --master-user-password 'P@ssw0rd1234!' \
    --allocated-storage 20 \
    --backup-retention-period 0 \
    --region "$REGION" \
    --no-publicly-accessible >/dev/null || true
done

# 1 DynamoDB table (on-demand) - no backups by AWS Backup by default
echo "Creating DynamoDB table test-ddb-unprotected"
aws dynamodb create-table \
  --table-name test-ddb-unprotected \
  --attribute-definitions AttributeName=pk,AttributeType=S \
  --key-schema AttributeName=pk,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" >/dev/null || true

echo "Test resources created. Please wait a minute for resources to appear via APIs."
