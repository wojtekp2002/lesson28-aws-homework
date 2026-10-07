# Cleanup

Po zaliczeniu zadania usuń zasoby, bo EC2 i RDS mogą generować koszty.

## S3

```powershell
aws s3 rm s3://lesson29-static-site-660140202510-20261007 --recursive
aws s3api delete-bucket --bucket lesson29-static-site-660140202510-20261007
```

## EC2

```powershell
aws ec2 terminate-instances --region eu-central-1 --instance-ids i-063c26d7e89f6e6c9
```

## RDS

```powershell
aws rds modify-db-instance --region eu-central-1 --db-instance-identifier lesson29-postgres-20261007 --no-deletion-protection --apply-immediately
aws rds delete-db-instance --region eu-central-1 --db-instance-identifier lesson29-postgres-20261007 --skip-final-snapshot
```

## Sieć

Po usunięciu EC2 i RDS można usunąć security groups, subnety, route table, internet gateway i VPC.

Identyfikatory są zapisane w:

```text
lesson29-aws-2/lesson29-summary.json
```
