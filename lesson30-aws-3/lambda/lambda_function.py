import json
import os
from datetime import datetime, timezone

import boto3


s3 = boto3.client("s3")


def lambda_handler(event, context):
    bucket_name = os.environ["BUCKET_NAME"]
    response = s3.list_objects_v2(Bucket=bucket_name)
    files = [item["Key"] for item in response.get("Contents", [])]

    body = {
        "current_time_utc": datetime.now(timezone.utc).isoformat(),
        "bucket": bucket_name,
        "files": files,
    }

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, ensure_ascii=False),
    }
