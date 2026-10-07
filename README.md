# Lesson 28 - AWS Homework

Repozytorium dokumentuje wykonanie zadaĹ„ z lekcji 28 AWS.

## Zadanie 1: kompleksowe Ĺ›rodowisko AWS

Wykonano:

- utworzenie grup IAM:
  - $GroupAdmin,
  - $GroupDeveloper,
  - $GroupReadonly;
- utworzenie uĹĽytkownikĂłw IAM:
  - $UserAdmin,
  - $UserDeveloper,
  - $UserReadonly;
- przypisanie uĹĽytkownikĂłw do grup;
- skonfigurowanie budĹĽetu $BudgetName na 5 USD miesiÄ™cznie;
- dodanie alertu email na adres: $AlertEmail;
- potwierdzenie dziaĹ‚ajÄ…cego AWS CLI dla uĹĽytkownika devops-admin.

## Zadanie 2: AWS CLI

Wykonano:

- utworzenie bucketa S3: $BucketName;
- upload pliku sample-file/testfile.txt;
- pobranie pliku do downloaded/testfile.txt;
- listowanie bucketĂłw S3;
- listowanie zawartoĹ›ci bucketa;
- listowanie AMI Amazon Linux 2;
- listowanie security groups;
- listowanie uĹĽytkownikĂłw IAM i szczegĂłĹ‚Ăłw uĹĽytkownikĂłw z zadania;
- listowanie przykĹ‚adowej usĹ‚ugi AWS przez CloudWatch alarms.

## Dowody wykonania

Wyniki komend sÄ… zapisane w katalogu ws-cli-output/.

## BezpieczeĹ„stwo

Do repozytorium nie dodano ĹĽadnych sekretĂłw AWS, access key ani secret key.
Bucket S3 ma wĹ‚Ä…czony blok publicznego dostÄ™pu, szyfrowanie SSE-S3 i tagi projektu.

## SprzÄ…tanie po zaliczeniu

`powershell
aws s3 rm s3://lesson28-aws-homework-660140202510-20261007 --recursive
aws s3api delete-bucket --bucket lesson28-aws-homework-660140202510-20261007
aws budgets delete-budget --account-id 660140202510 --budget-name lesson28-free-tier-safety-budget
`

UĹĽytkownikĂłw i grupy IAM usuĹ„ dopiero po upewnieniu siÄ™, ĹĽe nie sÄ… juĹĽ potrzebne.
