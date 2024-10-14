#! /bin/sh
# Requires AWS CLI
# Uploads a file to an S3 bucket
#
# Parameters
# LOCAL_DIRECTORY
# AWS_S3_BUCKET
# AWS_S3_DIRECTORY
echo "Syncing files from $LOCAL_DIRECTORY to $AWS_S3_BUCKET/$AWS_S3_DIRECTORY.";
aws s3 sync $LOCAL_DIRECTORY s3://$AWS_S3_BUCKET/$AWS_S3_DIRECTORY --output table --delete
if [ $? -ne 0 ]; then
  echo "An error occured while syncing: $?. Exiting."
  exit 1
fi

echo "S3_URL=https://${AWS_S3_BUCKET}.s3.amazonaws.com/${AWS_S3_DIRECTORY}/" >> "$GITHUB_OUTPUT"
echo "Success. Exiting."
exit 0;