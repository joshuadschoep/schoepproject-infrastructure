aws s3 sync templates/common s3://$AWS_S3_BUCKET/common --delete
aws s3 sync templates/deployed s3://$AWS_S3_BUCKET/deployed --delete