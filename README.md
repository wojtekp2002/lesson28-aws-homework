# AWS homework - lekcje 28, 29 i 30

Repozytorium zawiera wykonane zadania z lekcji 28, 29 i 30 AWS. Trzymam je razem, bo zadania dotyczą tej samej części kursu i łatwiej oddać jeden link niż kilka małych repozytoriów.

## Lekcja 28 - podstawy AWS i AWS CLI

W lekcji 28 wykonałem:

- utworzenie grup IAM:
  - `lesson28-admins`
  - `lesson28-developers`
  - `lesson28-readonly`
- utworzenie użytkowników IAM:
  - `lesson28.admin`
  - `lesson28.developer`
  - `lesson28.readonly`
- przypisanie użytkowników do odpowiednich grup,
- utworzenie budżetu `lesson28-free-tier-safety-budget` z limitem `5 USD`,
- dodanie alertu e-mail dla budżetu,
- sprawdzenie działania AWS CLI na użytkowniku `devops-admin`,
- utworzenie bucketa S3 `lesson28-aws-homework-660140202510-20261007`,
- upload i download pliku testowego,
- listowanie bucketów S3, AMI Amazon Linux 2, security groups, użytkowników IAM i budżetu.

Dowody dla lekcji 28 są w katalogu:

```text
aws-cli-output/
```

Najważniejsze pliki:

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

## Lekcja 29 - EC2, RDS PostgreSQL i strona na S3

Zadanie z lekcji 29 jest dodane jako osobny katalog:

```text
lesson29-aws-2/
```

W lekcji 29 wykonałem:

- utworzenie VPC `lesson29-vpc`,
- utworzenie dwóch subnetów w regionie `eu-central-1`,
- utworzenie security groups dla EC2 i RDS,
- otwarcie PostgreSQL tylko na porcie `5432` z EC2 do RDS,
- utworzenie instancji RDS PostgreSQL `lesson29-postgres-20261007`,
- utworzenie instancji EC2 `i-063c26d7e89f6e6c9`,
- uruchomienie inicjalizacji bazy z EC2 przez SSM,
- utworzenie tabeli `course_progress` i pierwszego wpisu w bazie PostgreSQL,
- utworzenie strony statycznej na S3.

Adres strony z lekcji 29:

```text
http://lesson29-static-site-660140202510-20261007.s3-website.eu-central-1.amazonaws.com
```

Dowody dla lekcji 29 są w:

```text
lesson29-aws-2/aws-cli-output/
lesson29-aws-2/docs/
lesson29-aws-2/site/
lesson29-aws-2/lesson29-summary.json
```

## Lekcja 30 - Lambda, ECR i ECS Fargate

Zadanie z lekcji 30 jest dodane jako osobny katalog:

```text
lesson30-aws-3/
```

W lekcji 30 wykonałem:

- utworzenie bucketa S3 `lesson30-serverless-660140202510-20261008`,
- utworzenie funkcji Lambda `lesson30-s3-time-function`,
- wystawienie Function URL,
- zwracanie aktualnego czasu UTC i listy plików z bucketa S3,
- przygotowanie własnego obrazu Docker z prostym serwerem Node.js,
- utworzenie repozytorium ECR `lesson30-fargate-app`,
- zbudowanie obrazu przez CodeBuild i wypchnięcie go do ECR,
- utworzenie klastra ECS `lesson30-fargate-cluster`,
- uruchomienie taska Fargate z obrazem z ECR,
- sprawdzenie odpowiedzi HTTP aplikacji kontenerowej,
- zatrzymanie taska Fargate po weryfikacji, żeby ograniczyć koszty.

Dowody dla lekcji 30 są w:

```text
lesson30-aws-3/aws-cli-output/
lesson30-aws-3/docs/
lesson30-aws-3/container-app/
lesson30-aws-3/lambda/
lesson30-aws-3/lesson30-summary.json
```

## Bezpieczeństwo

Do repozytorium nie dodano sekretów AWS, access key, secret key ani hasła do bazy RDS. W plikach wynikowych hasło do PostgreSQL zostało zamaskowane.


