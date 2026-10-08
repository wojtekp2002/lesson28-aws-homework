# Lekcja 30 - AWS Lambda, ECR i ECS Fargate

Ten katalog zawiera wykonanie zadania z lekcji 30. Dodałem go do tego samego repozytorium AWS, bo jest kontynuacją lekcji 28 i 29.

## Zadanie 1 - Lambda z Function URL

Zrobione:

- utworzony bucket S3 `lesson30-serverless-660140202510-20261008`,
- dodane przykładowe pliki do bucketa,
- utworzona rola IAM dla Lambdy,
- utworzona funkcja Lambda `lesson30-s3-time-function`,
- funkcja dostała zmienną środowiskową `BUCKET_NAME`,
- dodany Function URL bez autoryzacji do testów,
- Lambda zwraca aktualny czas UTC i listę plików z bucketa S3.

## Zadanie 2 - własny obraz Docker na ECS Fargate

Zrobione:

- przygotowany prosty serwer Node.js w katalogu `container-app/`,
- zbudowany własny obraz Docker,
- utworzone repozytorium ECR `lesson30-fargate-app`,
- obraz został wypchnięty do ECR,
- obraz został zbudowany przez CodeBuild, bo lokalny Docker Desktop miał problem z backendem,
- utworzony klaster ECS `lesson30-fargate-cluster`,
- zarejestrowana task definition dla Fargate,
- uruchomiony task Fargate z obrazem z ECR.
- task został sprawdzony przez HTTP i zatrzymany po weryfikacji, żeby ograniczyć koszty.

## Dowody

Wyniki komend są w katalogu:

```text
aws-cli-output/
```

Najważniejsze pliki:

- `aws-cli-output/00-caller-identity.json`
- `aws-cli-output/01-s3-bucket.txt`
- `aws-cli-output/02-lambda-function.json`
- `aws-cli-output/03-lambda-url.json`
- `aws-cli-output/04-lambda-response.json`
- `aws-cli-output/05-ecr-repository.json`
- `aws-cli-output/08-codebuild-result.json`
- `aws-cli-output/09-ecs-cluster.json`
- `aws-cli-output/10-task-definition.json`
- `aws-cli-output/11-run-task.json`
- `aws-cli-output/12-task-description.json`
- `aws-cli-output/14-fargate-http-response.json`
- `aws-cli-output/16-ecr-images.json`
- `aws-cli-output/17-task-stopped.json`
- `aws-cli-output/18-running-tasks-after-stop.json`
- `lesson30-summary.json`

## Uwaga o kosztach

Fargate nie jest typowym darmowym zasobem jak część Free Tier, dlatego task po weryfikacji został zatrzymany. Pozostałe zasoby można usunąć według instrukcji z `docs/cleanup.md`.
