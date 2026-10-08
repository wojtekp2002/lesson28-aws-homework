param(
    [string]$Region = "eu-central-1"
)

$ErrorActionPreference = "Stop"
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $PSNativeCommandUseErrorActionPreference = $true
}

function Write-AsciiFile {
    param(
        [string]$Path,
        [string]$Value
    )

    [System.IO.File]::WriteAllText($Path, $Value, [System.Text.Encoding]::ASCII)
}

function Invoke-AllowFail {
    param(
        [scriptblock]$Command
    )

    $PreviousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $Output = & $Command 2>$null
        $ExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $PreviousErrorActionPreference
    }

    [pscustomobject]@{
        Output = $Output
        ExitCode = $ExitCode
    }
}

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$OutputDir = Join-Path $ProjectRoot "aws-cli-output"
$BuildDir = Join-Path $ProjectRoot ".build"
$LambdaZip = Join-Path $BuildDir "lambda-function.zip"
$DateSuffix = "20261008"

New-Item -ItemType Directory -Force $OutputDir | Out-Null
New-Item -ItemType Directory -Force $BuildDir | Out-Null

$Caller = aws sts get-caller-identity | ConvertFrom-Json
$AccountId = $Caller.Account
$Caller | ConvertTo-Json -Depth 5 | Set-Content -Encoding utf8 (Join-Path $OutputDir "00-caller-identity.json")

$BucketName = "lesson30-serverless-$AccountId-$DateSuffix"
$LambdaName = "lesson30-s3-time-function"
$LambdaRoleName = "lesson30-lambda-role"
$EcrRepoName = "lesson30-fargate-app"
$CodeBuildProject = "lesson30-ecr-image-build"
$CodeBuildRoleName = "lesson30-codebuild-role"
$ClusterName = "lesson30-fargate-cluster"
$TaskFamily = "lesson30-fargate-task"
$LogGroup = "/ecs/lesson30-fargate-app"

$BucketLookup = Invoke-AllowFail { aws s3api head-bucket --bucket $BucketName }
if ($BucketLookup.ExitCode -ne 0) {
    aws s3api create-bucket `
        --bucket $BucketName `
        --region $Region `
        --create-bucket-configuration LocationConstraint=$Region | Out-Null
}

"lesson 30 lambda test file" | Set-Content -Encoding utf8 (Join-Path $BuildDir "sample-a.txt")
"serverless and containers in aws" | Set-Content -Encoding utf8 (Join-Path $BuildDir "sample-b.txt")
aws s3 cp (Join-Path $BuildDir "sample-a.txt") "s3://$BucketName/input/sample-a.txt" | Out-Null
aws s3 cp (Join-Path $BuildDir "sample-b.txt") "s3://$BucketName/input/sample-b.txt" | Out-Null
aws s3api list-objects-v2 --bucket $BucketName | Set-Content -Encoding utf8 (Join-Path $OutputDir "01-s3-bucket.txt")

$AssumeRolePolicy = @{
    Version = "2012-10-17"
    Statement = @(
        @{
            Effect = "Allow"
            Principal = @{ Service = "lambda.amazonaws.com" }
            Action = "sts:AssumeRole"
        }
    )
} | ConvertTo-Json -Depth 10

$AssumeRoleFile = Join-Path $BuildDir "lambda-assume-role.json"
$AssumeRolePolicy | Set-Content -Encoding ascii $AssumeRoleFile

$RoleArn = $null
$RoleLookup = Invoke-AllowFail { aws iam get-role --role-name $LambdaRoleName }
if ($RoleLookup.ExitCode -eq 0) {
    $RoleArn = ($RoleLookup.Output | ConvertFrom-Json).Role.Arn
}
else {
    $RoleArn = (aws iam create-role --role-name $LambdaRoleName --assume-role-policy-document "file://$AssumeRoleFile" | ConvertFrom-Json).Role.Arn
}

aws iam attach-role-policy `
    --role-name $LambdaRoleName `
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole | Out-Null

$S3Policy = @{
    Version = "2012-10-17"
    Statement = @(
        @{
            Effect = "Allow"
            Action = @("s3:ListBucket")
            Resource = "arn:aws:s3:::$BucketName"
        },
        @{
            Effect = "Allow"
            Action = @("s3:GetObject")
            Resource = "arn:aws:s3:::$BucketName/*"
        }
    )
} | ConvertTo-Json -Depth 10

$S3PolicyFile = Join-Path $BuildDir "lambda-s3-policy.json"
$S3Policy | Set-Content -Encoding ascii $S3PolicyFile
aws iam put-role-policy --role-name $LambdaRoleName --policy-name lesson30-s3-list-policy --policy-document "file://$S3PolicyFile" | Out-Null

Start-Sleep -Seconds 10

Compress-Archive -Path (Join-Path $ProjectRoot "lambda\lambda_function.py") -DestinationPath $LambdaZip -Force

$FunctionExists = $true
$FunctionLookup = Invoke-AllowFail { aws lambda get-function --region $Region --function-name $LambdaName }
if ($FunctionLookup.ExitCode -ne 0) {
    $FunctionExists = $false
}

if ($FunctionExists) {
    aws lambda update-function-code --region $Region --function-name $LambdaName --zip-file "fileb://$LambdaZip" | Out-Null
    aws lambda wait function-updated --region $Region --function-name $LambdaName
    aws lambda update-function-configuration --region $Region --function-name $LambdaName --environment "Variables={BUCKET_NAME=$BucketName}" | Out-Null
    aws lambda wait function-updated --region $Region --function-name $LambdaName
}
else {
    aws lambda create-function `
        --region $Region `
        --function-name $LambdaName `
        --runtime python3.12 `
        --role $RoleArn `
        --handler lambda_function.lambda_handler `
        --zip-file "fileb://$LambdaZip" `
        --environment "Variables={BUCKET_NAME=$BucketName}" | Out-Null
}

aws lambda wait function-active --region $Region --function-name $LambdaName
aws lambda get-function --region $Region --function-name $LambdaName | Set-Content -Encoding utf8 (Join-Path $OutputDir "02-lambda-function.json")

$FunctionUrl = $null
$FunctionUrlLookup = Invoke-AllowFail { aws lambda get-function-url-config --region $Region --function-name $LambdaName }
if ($FunctionUrlLookup.ExitCode -eq 0) {
    $FunctionUrl = ($FunctionUrlLookup.Output | ConvertFrom-Json).FunctionUrl
}
else {
    $FunctionUrl = (aws lambda create-function-url-config --region $Region --function-name $LambdaName --auth-type NONE | ConvertFrom-Json).FunctionUrl
}

$null = Invoke-AllowFail {
    aws lambda add-permission `
        --region $Region `
        --function-name $LambdaName `
        --statement-id FunctionUrlAllowPublicAccess `
        --action lambda:InvokeFunctionUrl `
        --principal "*" `
        --function-url-auth-type NONE
}

$null = Invoke-AllowFail {
    aws lambda add-permission `
        --region $Region `
        --function-name $LambdaName `
        --statement-id FunctionUrlInvokeFunctionPublicAccess `
        --action lambda:InvokeFunction `
        --principal "*" `
        --invoked-via-function-url
}

aws lambda get-function-url-config --region $Region --function-name $LambdaName | Set-Content -Encoding utf8 (Join-Path $OutputDir "03-lambda-url.json")
Invoke-RestMethod -Uri $FunctionUrl | ConvertTo-Json -Depth 10 | Set-Content -Encoding utf8 (Join-Path $OutputDir "04-lambda-response.json")

$RepositoryUri = $null
$RepositoryLookup = Invoke-AllowFail { aws ecr describe-repositories --region $Region --repository-names $EcrRepoName }
if ($RepositoryLookup.ExitCode -eq 0) {
    $RepositoryUri = ($RepositoryLookup.Output | ConvertFrom-Json).repositories[0].repositoryUri
}
else {
    $RepositoryUri = (aws ecr create-repository --region $Region --repository-name $EcrRepoName | ConvertFrom-Json).repository.repositoryUri
}
aws ecr describe-repositories --region $Region --repository-names $EcrRepoName | Set-Content -Encoding utf8 (Join-Path $OutputDir "05-ecr-repository.json")

$CodeBuildAssumePolicy = @{
    Version = "2012-10-17"
    Statement = @(
        @{
            Effect = "Allow"
            Principal = @{ Service = "codebuild.amazonaws.com" }
            Action = "sts:AssumeRole"
        }
    )
} | ConvertTo-Json -Depth 10

$CodeBuildAssumeFile = Join-Path $BuildDir "codebuild-assume-role.json"
$CodeBuildAssumePolicy | Set-Content -Encoding ascii $CodeBuildAssumeFile

$CodeBuildRoleArn = $null
$CodeBuildRoleLookup = Invoke-AllowFail { aws iam get-role --role-name $CodeBuildRoleName }
if ($CodeBuildRoleLookup.ExitCode -eq 0) {
    $CodeBuildRoleArn = ($CodeBuildRoleLookup.Output | ConvertFrom-Json).Role.Arn
}
else {
    $CodeBuildRoleArn = (aws iam create-role --role-name $CodeBuildRoleName --assume-role-policy-document "file://$CodeBuildAssumeFile" | ConvertFrom-Json).Role.Arn
    Start-Sleep -Seconds 20
}

$CodeBuildPolicy = @{
    Version = "2012-10-17"
    Statement = @(
        @{
            Effect = "Allow"
            Action = @(
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ecr:GetAuthorizationToken"
            )
            Resource = "*"
        },
        @{
            Effect = "Allow"
            Action = @(
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:UploadLayerPart",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer"
            )
            Resource = "arn:aws:ecr:${Region}:${AccountId}:repository/$EcrRepoName"
        },
        @{
            Effect = "Allow"
            Action = @("s3:GetObject", "s3:GetObjectVersion", "s3:PutObject")
            Resource = "arn:aws:s3:::$BucketName/codebuild/*"
        }
    )
} | ConvertTo-Json -Depth 10

$CodeBuildPolicyFile = Join-Path $BuildDir "codebuild-policy.json"
$CodeBuildPolicy | Set-Content -Encoding ascii $CodeBuildPolicyFile
aws iam put-role-policy --role-name $CodeBuildRoleName --policy-name lesson30-codebuild-policy --policy-document "file://$CodeBuildPolicyFile" | Out-Null
Start-Sleep -Seconds 20

$SourceDir = Join-Path $BuildDir "codebuild-source"
$SourceZip = Join-Path $BuildDir "codebuild-source.zip"
Remove-Item -Recurse -Force $SourceDir -ErrorAction SilentlyContinue
Remove-Item -Force $SourceZip -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $SourceDir | Out-Null
Copy-Item -Recurse (Join-Path $ProjectRoot "container-app\*") $SourceDir

@"
version: 0.2

phases:
  pre_build:
    commands:
      - aws ecr get-login-password --region `$AWS_DEFAULT_REGION | docker login --username AWS --password-stdin `$REPOSITORY_URI
  build:
    commands:
      - ls -la
      - docker build -t lesson30-fargate-app:latest .
      - docker tag lesson30-fargate-app:latest `$REPOSITORY_URI:latest
  post_build:
    commands:
      - docker push `$REPOSITORY_URI:latest
"@ | Set-Content -Encoding ascii (Join-Path $SourceDir "buildspec.yml")

Compress-Archive -Path (Join-Path $SourceDir "*") -DestinationPath $SourceZip -Force
aws s3 cp $SourceZip "s3://$BucketName/codebuild/source.zip" | Out-Null

$CodeBuildConfigFile = Join-Path $BuildDir "codebuild-project.json"
$CodeBuildConfig = @{
    name = $CodeBuildProject
    source = @{
        type = "S3"
        location = "$BucketName/codebuild/source.zip"
    }
    artifacts = @{
        type = "NO_ARTIFACTS"
    }
    environment = @{
        type = "LINUX_CONTAINER"
        image = "aws/codebuild/standard:7.0"
        computeType = "BUILD_GENERAL1_SMALL"
        privilegedMode = $true
        environmentVariables = @(
            @{
                name = "REPOSITORY_URI"
                value = $RepositoryUri
                type = "PLAINTEXT"
            },
            @{
                name = "AWS_DEFAULT_REGION"
                value = $Region
                type = "PLAINTEXT"
            }
        )
    }
    serviceRole = $CodeBuildRoleArn
} | ConvertTo-Json -Depth 20
$CodeBuildConfig | Set-Content -Encoding utf8 $CodeBuildConfigFile
$CodeBuildConfig | Set-Content -Encoding ascii $CodeBuildConfigFile

$CodeBuildProjectLookup = Invoke-AllowFail { aws codebuild batch-get-projects --region $Region --names $CodeBuildProject }
$ProjectExists = $false
if ($CodeBuildProjectLookup.ExitCode -eq 0) {
    $ProjectInfo = aws codebuild batch-get-projects --region $Region --names $CodeBuildProject | ConvertFrom-Json
    $ProjectExists = $ProjectInfo.projects.Count -gt 0
}

if (-not $ProjectExists) {
    $CreateProjectResult = Invoke-AllowFail { aws codebuild create-project --region $Region --cli-input-json "file://$CodeBuildConfigFile" }
    if ($CreateProjectResult.ExitCode -ne 0) {
        Start-Sleep -Seconds 30
        aws codebuild create-project --region $Region --cli-input-json "file://$CodeBuildConfigFile" | Set-Content -Encoding utf8 (Join-Path $OutputDir "06-codebuild-project.json")
    }
    else {
        $CreateProjectResult.Output | Set-Content -Encoding utf8 (Join-Path $OutputDir "06-codebuild-project.json")
    }
}
else {
    aws codebuild update-project --region $Region --cli-input-json "file://$CodeBuildConfigFile" | Set-Content -Encoding utf8 (Join-Path $OutputDir "06-codebuild-project.json")
}

$BuildId = (aws codebuild start-build --region $Region --project-name $CodeBuildProject | Tee-Object -FilePath (Join-Path $OutputDir "07-codebuild-start.json") | ConvertFrom-Json).build.id
if (-not $BuildId) {
    throw "CodeBuild build id was not returned"
}

do {
    Start-Sleep -Seconds 15
    $BuildInfo = aws codebuild batch-get-builds --region $Region --ids $BuildId | ConvertFrom-Json
    $BuildStatus = $BuildInfo.builds[0].buildStatus
} while ($BuildStatus -in @("IN_PROGRESS", "QUEUED"))

$BuildInfo | ConvertTo-Json -Depth 20 | Set-Content -Encoding utf8 (Join-Path $OutputDir "08-codebuild-result.json")
if ($BuildStatus -ne "SUCCEEDED") {
    throw "CodeBuild failed with status $BuildStatus"
}

aws ecs create-cluster --region $Region --cluster-name $ClusterName | Set-Content -Encoding utf8 (Join-Path $OutputDir "09-ecs-cluster.json")
$null = Invoke-AllowFail { aws logs create-log-group --region $Region --log-group-name $LogGroup }

$TaskExecutionRoleArn = "arn:aws:iam::${AccountId}:role/ecsTaskExecutionRole"
$TaskRoleLookup = Invoke-AllowFail { aws iam get-role --role-name ecsTaskExecutionRole }
if ($TaskRoleLookup.ExitCode -ne 0) {
    $TaskAssumePolicy = @{
        Version = "2012-10-17"
        Statement = @(
            @{
                Effect = "Allow"
                Principal = @{ Service = "ecs-tasks.amazonaws.com" }
                Action = "sts:AssumeRole"
            }
        )
    } | ConvertTo-Json -Depth 10

    $TaskAssumeFile = Join-Path $BuildDir "ecs-task-assume-role.json"
    $TaskAssumePolicy | Set-Content -Encoding ascii $TaskAssumeFile
    aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document "file://$TaskAssumeFile" | Out-Null
    aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy | Out-Null
    Start-Sleep -Seconds 10
}

$TaskDefinitionFile = Join-Path $BuildDir "task-definition.json"
$TaskDefinition = @{
    family = $TaskFamily
    networkMode = "awsvpc"
    requiresCompatibilities = @("FARGATE")
    cpu = "256"
    memory = "512"
    executionRoleArn = $TaskExecutionRoleArn
    containerDefinitions = @(
        @{
            name = "lesson30-app"
            image = "${RepositoryUri}:latest"
            essential = $true
            portMappings = @(
                @{
                    containerPort = 8080
                    protocol = "tcp"
                }
            )
            logConfiguration = @{
                logDriver = "awslogs"
                options = @{
                    "awslogs-group" = $LogGroup
                    "awslogs-region" = $Region
                    "awslogs-stream-prefix" = "ecs"
                }
            }
        }
    )
} | ConvertTo-Json -Depth 20
$TaskDefinition | Set-Content -Encoding utf8 $TaskDefinitionFile
$TaskDefinition | Set-Content -Encoding ascii $TaskDefinitionFile

$TaskDefinitionArn = (aws ecs register-task-definition --region $Region --cli-input-json "file://$TaskDefinitionFile" | Tee-Object -FilePath (Join-Path $OutputDir "10-task-definition.json") | ConvertFrom-Json).taskDefinition.taskDefinitionArn

$DefaultVpcId = (aws ec2 describe-vpcs --region $Region --filters Name=is-default,Values=true | ConvertFrom-Json).Vpcs[0].VpcId
$SubnetIds = (aws ec2 describe-subnets --region $Region --filters Name=vpc-id,Values=$DefaultVpcId | ConvertFrom-Json).Subnets | Select-Object -First 2 -ExpandProperty SubnetId

$SecurityGroupName = "lesson30-fargate-sg"
$SecurityGroupId = $null
$SecurityGroupLookup = aws ec2 describe-security-groups --region $Region --filters Name=group-name,Values=$SecurityGroupName Name=vpc-id,Values=$DefaultVpcId | ConvertFrom-Json
if ($SecurityGroupLookup.SecurityGroups.Count -gt 0) {
    $SecurityGroupId = $SecurityGroupLookup.SecurityGroups[0].GroupId
}
else {
    $SecurityGroupId = (aws ec2 create-security-group --region $Region --group-name $SecurityGroupName --description "Lesson 30 Fargate HTTP access" --vpc-id $DefaultVpcId | ConvertFrom-Json).GroupId
    aws ec2 authorize-security-group-ingress --region $Region --group-id $SecurityGroupId --protocol tcp --port 8080 --cidr 0.0.0.0/0 | Out-Null
}

$SubnetCsv = ($SubnetIds -join ",")
$NetworkConfig = "awsvpcConfiguration={subnets=[$SubnetCsv],securityGroups=[$SecurityGroupId],assignPublicIp=ENABLED}"

$RunTask = aws ecs run-task `
    --region $Region `
    --cluster $ClusterName `
    --launch-type FARGATE `
    --task-definition $TaskDefinitionArn `
    --network-configuration $NetworkConfig | Tee-Object -FilePath (Join-Path $OutputDir "11-run-task.json") | ConvertFrom-Json

$TaskArn = $RunTask.tasks[0].taskArn
Start-Sleep -Seconds 30
aws ecs describe-tasks --region $Region --cluster $ClusterName --tasks $TaskArn | Set-Content -Encoding utf8 (Join-Path $OutputDir "12-task-description.json")

$Summary = [ordered]@{
    AccountId = $AccountId
    CallerArn = $Caller.Arn
    Region = $Region
    BucketName = $BucketName
    LambdaFunction = $LambdaName
    FunctionUrl = $FunctionUrl
    EcrRepository = $EcrRepoName
    EcrRepositoryUri = $RepositoryUri
    CodeBuildProject = $CodeBuildProject
    CodeBuildBuildId = $BuildId
    CodeBuildStatus = $BuildStatus
    EcsCluster = $ClusterName
    TaskDefinition = $TaskDefinitionArn
    TaskArn = $TaskArn
    VpcId = $DefaultVpcId
    Subnets = $SubnetIds
    SecurityGroupId = $SecurityGroupId
}

$Summary | ConvertTo-Json -Depth 10 | Set-Content -Encoding utf8 (Join-Path $ProjectRoot "lesson30-summary.json")
