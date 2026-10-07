# Verification

Region: `eu-central-1`

## Sieć

- VPC: `vpc-0eb32900767e3658b`
- subnet 1: `subnet-06a67a2974b0567a7`
- subnet 2: `subnet-0253b2a064bb09d03`
- security group EC2: `sg-0cf71218657bf066c`
- security group RDS: `sg-09b8de5e4321c4b76`
- port PostgreSQL: `5432`

## RDS PostgreSQL

```text
lesson29-postgres-20261007
lesson29-postgres-20261007.crqsuq4wek4x.eu-central-1.rds.amazonaws.com
```

## EC2

```text
i-063c26d7e89f6e6c9
```

EC2 przez SSM utworzyło tabelę `course_progress` i dodało pierwszy wpis do bazy.

## S3 website

```text
http://lesson29-static-site-660140202510-20261007.s3-website.eu-central-1.amazonaws.com
```

Dowody wykonania są w katalogu:

```text
lesson29-aws-2/aws-cli-output/
```
