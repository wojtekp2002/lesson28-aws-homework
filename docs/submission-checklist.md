# Verification

Data wykonania: 2026-10-07T14:29:05Z

Region AWS: $Region

Konto AWS: $AccountId

Caller ARN:

`	ext
arn:aws:iam::660140202510:user/devops-admin
`

Alert budĹĽetowy:

`	ext
wojtek.pasiu@gmail.com
`

Bucket:

`	ext
lesson28-aws-homework-660140202510-20261007
`

NajwaĹĽniejsze dowody:

- ws-cli-output/00-caller-identity.json
- ws-cli-output/01-s3-buckets.txt
- ws-cli-output/02-s3-bucket-contents.txt
- ws-cli-output/03-amazon-linux-2-amis.txt
- ws-cli-output/04-security-groups.txt
- ws-cli-output/05-iam-users.json
- ws-cli-output/09-budget.json
- downloaded/testfile.txt
"@ | Set-Content -Encoding utf8 "docs/verification.md"

@"
# Submission checklist

JeĹĽeli prowadzÄ…cy wymaga screenĂłw, zrĂłb je z AWS Console:

1. IAM -> User groups: widoczne lesson28-admins, lesson28-developers, lesson28-readonly.
2. IAM -> Users: widoczne lesson28.admin, lesson28.developer, lesson28.readonly, devops-admin.
3. Billing and Cost Management -> Budgets: budĹĽet lesson28-free-tier-safety-budget.
4. S3 -> bucket $BucketName -> plik 	estfile.txt.
5. Terminal z wynikami z katalogu ws-cli-output/.

Do oddania moĹĽna teĹĽ uĹĽyÄ‡ samego repozytorium z plikami wynikowymi, jeĹ›li screeny nie sÄ… obowiÄ…zkowe.
