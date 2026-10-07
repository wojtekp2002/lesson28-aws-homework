# Cleanup

Po zaliczeniu zadania warto usunac zasoby, zeby nic nie zostalo w AWS bez potrzeby.

## S3

```powershell
aws s3 rm s3://lesson28-aws-homework-660140202510-20261007 --recursive
aws s3api delete-bucket --bucket lesson28-aws-homework-660140202510-20261007
```

## Budget

```powershell
aws budgets delete-budget --account-id 660140202510 --budget-name lesson28-free-tier-safety-budget
```

## IAM

IAM usuwaj ostroznie. Najpierw odepnij uzytkownikow od grup, potem polityki od grup, a dopiero na koncu usun grupy i uzytkownikow.

Utworzone elementy:

- grupy:
  - `lesson28-admins`
  - `lesson28-developers`
  - `lesson28-readonly`
- uzytkownicy:
  - `lesson28.admin`
  - `lesson28.developer`
  - `lesson28.readonly`
