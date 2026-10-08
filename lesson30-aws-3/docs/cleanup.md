# Cleanup

Po zaliczeniu zadania usuń zasoby, bo ECS Fargate, ECR, Lambda i S3 mogą generować koszty albo zostawiać aktywne usługi.

## ECS Fargate

```powershell
aws ecs stop-task --region eu-central-1 --cluster lesson30-fargate-cluster --task <TASK_ARN>
aws ecs delete-cluster --region eu-central-1 --cluster lesson30-fargate-cluster
```

Task z weryfikacji został już zatrzymany, ale klaster i task definition mogą dalej istnieć jako dowód.

## CodeBuild

```powershell
aws codebuild delete-project --region eu-central-1 --name lesson30-ecr-image-build
aws iam delete-role-policy --role-name lesson30-codebuild-role --policy-name lesson30-codebuild-policy
aws iam delete-role --role-name lesson30-codebuild-role
```

## ECR

```powershell
aws ecr delete-repository --region eu-central-1 --repository-name lesson30-fargate-app --force
```

## Lambda

```powershell
aws lambda delete-function --region eu-central-1 --function-name lesson30-s3-time-function
aws iam detach-role-policy --role-name lesson30-lambda-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role-policy --role-name lesson30-lambda-role --policy-name lesson30-s3-list-policy
aws iam delete-role --role-name lesson30-lambda-role
```

## S3

```powershell
aws s3 rm s3://lesson30-serverless-660140202510-20261008 --recursive
aws s3api delete-bucket --bucket lesson30-serverless-660140202510-20261008 --region eu-central-1
```

## Security group

```powershell
aws ec2 delete-security-group --region eu-central-1 --group-id <SECURITY_GROUP_ID>
```

## CloudWatch Logs

```powershell
aws logs delete-log-group --region eu-central-1 --log-group-name /ecs/lesson30-fargate-app
aws logs delete-log-group --region eu-central-1 --log-group-name /aws/codebuild/lesson30-ecr-image-build
aws logs delete-log-group --region eu-central-1 --log-group-name /aws/lambda/lesson30-s3-time-function
```
