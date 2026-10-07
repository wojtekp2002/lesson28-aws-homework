# Cleanup

`powershell
aws s3 rm s3://lesson28-aws-homework-660140202510-20261007 --recursive
aws s3api delete-bucket --bucket lesson28-aws-homework-660140202510-20261007
aws budgets delete-budget --account-id 660140202510 --budget-name lesson28-free-tier-safety-budget
`

IAM cleanup wymaga najpierw odpiÄ™cia polityk i usuniÄ™cia uĹĽytkownikĂłw z grup.
