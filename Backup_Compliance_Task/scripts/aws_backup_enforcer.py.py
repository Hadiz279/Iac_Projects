#!/usr/bin/env python3
"""
aws_backup_enforcer.py
Detect unprotected EC2/EBS/RDS and tag them for backup (backup=auto).
Requires boto3 installed and AWS credentials available.
"""

import boto3
import os
import sys
from botocore.config import Config

REGION = os.getenv('AWS_REGION', os.getenv('AWS_DEFAULT_REGION', 'us-east-1'))
TAG_KEY = os.getenv('BACKUP_TAG_KEY', 'backup')
TAG_VAL = os.getenv('BACKUP_TAG_VALUE', 'auto')
VAULT_NAME = os.getenv('BACKUP_VAULT', 'default-free-tier-vault')
# Set START_IMMEDIATE to "true" to try start_backup_job for newly detected resources (use with care)
START_IMMEDIATE = os.getenv('START_IMMEDIATE', 'false').lower() == 'true'
ROLE_ARN = os.getenv('BACKUP_ROLE_ARN')  # optional if start backup is used

cfg = Config(retries={'max_attempts': 6, 'mode': 'standard'})
session = boto3.Session(region_name=REGION)
backup = session.client('backup', config=cfg)
ec2 = session.client('ec2', config=cfg)
rds = session.client('rds', config=cfg)
sts = session.client('sts', config=cfg)
account_id = sts.get_caller_identity()['Account']

# collect protected resource ARNs
protected = set()
paginator = backup.get_paginator('list_protected_resources')
for page in paginator.paginate():
    for pr in page.get('Results', []):
        protected.add(pr['ResourceArn'])

print(f"Found {len(protected)} protected resources in Backup")

changed = False

# EC2 Instances
print("Checking EC2 instances...")
instances = []
for page in ec2.get_paginator('describe_instances').paginate():
    for r in page.get('Reservations', []):
        for i in r.get('Instances', []):
            instances.append(i)
for inst in instances:
    iid = inst['InstanceId']
    arn = f"arn:aws:ec2:{REGION}:{account_id}:instance/{iid}"
    if arn not in protected:
        print(f"Tagging unprotected EC2 {iid}")
        ec2.create_tags(Resources=[iid], Tags=[{'Key': TAG_KEY, 'Value': TAG_VAL}])
        changed = True
    else:
        print(f"OK EC2 {iid} protected")

# EBS Volumes
print("Checking EBS volumes...")
for page in ec2.get_paginator('describe_volumes').paginate():
    for vol in page.get('Volumes', []):
        vid = vol['VolumeId']
        arn = f"arn:aws:ec2:{REGION}:{account_id}:volume/{vid}"
        if arn not in protected:
            print(f"Tagging unprotected Volume {vid}")
            ec2.create_tags(Resources=[vid], Tags=[{'Key': TAG_KEY, 'Value': TAG_VAL}])
            changed = True
        else:
            print(f"OK Volume {vid} protected")

# RDS Instances
print("Checking RDS instances...")
for page in rds.get_paginator('describe_db_instances').paginate():
    for db in page.get('DBInstances', []):
        db_arn = db['DBInstanceArn']
        db_id = db['DBInstanceIdentifier']
        if db_arn not in protected:
            print(f"Tagging unprotected RDS {db_id}")
            rds.add_tags_to_resource(ResourceName=db_arn, Tags=[{'Key': TAG_KEY, 'Value': TAG_VAL}])
            changed = True
        else:
            print(f"OK RDS {db_id} protected")

print("changed_applied=", changed)