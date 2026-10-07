# Lekcja 29 - AWS EC2, RDS PostgreSQL i S3

Ten katalog zawiera wykonanie zadań z lekcji 29. Dodałem go do repozytorium z lekcji 28, bo oba tematy dotyczą AWS i tak jest prościej oddać całość jednym linkiem.

## Zadanie 1 - EC2 + RDS PostgreSQL

Zrobione:

- utworzona sieć VPC `lesson29-vpc`,
- utworzone dwie podsieci w regionie `eu-central-1`,
- utworzone security groups dla EC2 i RDS,
- RDS używa portu PostgreSQL `5432`,
- ruch do RDS jest dopuszczony tylko z security group EC2,
- utworzona instancja RDS PostgreSQL:
  - identyfikator: `lesson29-postgres-20261007`,
  - endpoint: `lesson29-postgres-20261007.crqsuq4wek4x.eu-central-1.rds.amazonaws.com`,
- utworzona instancja EC2:
  - instance id: `i-063c26d7e89f6e6c9`,
- EC2 przez SSM utworzyło w bazie tabelę `course_progress` i dodało pierwszy wpis.

## Zadanie 2 - strona statyczna S3

Zrobione:

- bucket S3 w regionie `eu-central-1`,
- bucket: `lesson29-static-site-660140202510-20261007`,
- plik strony: `site/index.html`,
- włączony static website hosting,
- dodana polityka public read dla obiektów strony.

Adres strony:

```text
http://lesson29-static-site-660140202510-20261007.s3-website.eu-central-1.amazonaws.com
```

## Dowody

Wyniki komend są w katalogu:

```text
aws-cli-output/
```

Najważniejsze pliki:

- `aws-cli-output/00-caller-identity.json`
- `aws-cli-output/01-vpc.txt`
- `aws-cli-output/02-subnets.txt`
- `aws-cli-output/03-security-groups.txt`
- `aws-cli-output/04-rds-postgres.txt`
- `aws-cli-output/05-ec2-initializer.txt`
- `aws-cli-output/06-s3-site-objects.txt`
- `aws-cli-output/07-s3-website.json`
- `aws-cli-output/08-s3-policy.json`
- `aws-cli-output/09-db-init-ssm.json`
- `lesson29-summary.json`

## Uwaga o kosztach

RDS i EC2 to realne zasoby AWS. Po zaliczeniu zadania trzeba je usunąć według instrukcji z `docs/cleanup.md`.
