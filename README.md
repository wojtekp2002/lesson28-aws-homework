# Lesson 28 - AWS homework

Repozytorium zawiera wykonane zadania z lekcji 28 AWS.

## Zadanie 1 - srodowisko AWS

Zrobione:

- utworzone grupy IAM:
  - `lesson28-admins`
  - `lesson28-developers`
  - `lesson28-readonly`
- utworzeni uzytkownicy IAM:
  - `lesson28.admin`
  - `lesson28.developer`
  - `lesson28.readonly`
- uzytkownicy zostali przypisani do odpowiednich grup
- utworzony budzet:
  - `lesson28-free-tier-safety-budget`
  - limit: `5 USD`
  - status: `HEALTHY`
- dodany alert email:
  - `wojtek.pasiu@gmail.com`
- AWS CLI dziala na uzytkowniku:
  - `arn:aws:iam::660140202510:user/devops-admin`

## Zadanie 2 - AWS CLI

Zrobione:

- utworzony bucket S3:
  - `lesson28-aws-homework-660140202510-20261007`
- wrzucony plik:
  - `sample-file/testfile.txt`
- pobrany plik:
  - `downloaded/testfile.txt`
- wylistowane buckety S3
- wylistowana zawartosc bucketa
- wylistowane AMI Amazon Linux 2
- wylistowane security groups
- wylistowani uzytkownicy IAM
- sprawdzone szczegoly uzytkownikow z zadania
- sprawdzony budzet
- sprawdzone szyfrowanie i public access block dla S3

## Dowody wykonania

Wyniki komend sa w katalogu:

```text
aws-cli-output/
```

Najwazniejsze pliki:

- `aws-cli-output/00-caller-identity.json`
- `aws-cli-output/01-s3-buckets.txt`
- `aws-cli-output/02-s3-bucket-contents.txt`
- `aws-cli-output/03-amazon-linux-2-amis.txt`
- `aws-cli-output/04-security-groups.txt`
- `aws-cli-output/05-iam-users.json`
- `aws-cli-output/09-budget.json`
- `aws-cli-output/13-s3-encryption.json`
- `aws-cli-output/14-s3-public-access-block.json`
- `downloaded/testfile.txt`

## Bezpieczenstwo

Do repozytorium nie dodano zadnych sekretow AWS, access key ani secret key. Bucket S3 ma wlaczone:

- blokade publicznego dostepu
- szyfrowanie SSE-S3
- tagi projektu

