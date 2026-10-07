# Submission checklist

Do oddania wystarczy link do repozytorium. Jezeli prowadzacy wymaga screenow, zrob je z tych miejsc w AWS Console:

1. IAM -> User groups
   - widoczne: `lesson28-admins`, `lesson28-developers`, `lesson28-readonly`

2. IAM -> Users
   - widoczne: `lesson28.admin`, `lesson28.developer`, `lesson28.readonly`, `devops-admin`

3. Billing and Cost Management -> Budgets
   - widoczny budzet: `lesson28-free-tier-safety-budget`
   - limit: `5 USD`

4. S3 -> Buckets
   - bucket: `lesson28-aws-homework-660140202510-20261007`
   - plik: `testfile.txt`

5. Terminal albo pliki z repo
   - katalog: `aws-cli-output/`
   - najwazniejsze wyniki: S3, IAM, AMI, security groups, budget

W repo sa juz zapisane wyniki komend, wiec screeny sa tylko dodatkiem, jezeli ktos ich wymaga.
