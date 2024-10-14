#! /bin/sh
# Requires AWS CLI
# Creates and deploys a stack change set -- will 
# create a stack if doesn't exist under this name
# else creates an update
#
# Parameters
# AWS_REGION region of the stack
# STACK_NAME name of the cloudformation stack
# TEMPLATE_URL S3 url of the template to make updates from -- must start with https://
# CHANGESET_NAME Label for this changeset
# CHANGESET_DESCRIPTION Description of this changeset
# CHANGESET_ROLE Role to use while creating this changeset
echo "Checking for existence of stack ${STACK_NAME}."
aws cloudformation describe-stacks --stack-name $STACK_NAME > /dev/null 2>&1
result=$?;

if [ $result -eq 254 ]; then
  echo "Cannot find stack $STACK_NAME. Creating a changeset to create a fresh stack.";
  CHANGESET_TYPE=CREATE;
elif [ $result -eq 0 ]; then
  echo "Found stack $STACK_NAME. Creating a changeset to update this stack.";
  CHANGESET_TYPE=UPDATE;
else
  echo "An error has occured: $? while finding stack $STACK_NAME. Exiting.";
  exit 1;
fi

echo "Creating changeset ${CHANGESET_NAME} for stack ${STACK_NAME}"
echo "aws cloudformation create-change-set \
  --stack-name $STACK_NAME \
  --template-url $TEMPLATE_URL \
  --change-set-type $CHANGESET_TYPE \
  --change-set-name $CHANGESET_NAME \
  --role-arn $CHANGESET_ROLE \
  --description $CHANGESET_DESCRIPTION \
  --output json"

CHANGESET=$(aws cloudformation create-change-set \
  --stack-name $STACK_NAME \
  --template-url $TEMPLATE_URL \
  --change-set-type $CHANGESET_TYPE \
  --change-set-name $CHANGESET_NAME \
  --role-arn $CHANGESET_ROLE \
  --description "${CHANGESET_DESCRIPTION}" \
  --output json)

if [ $? -ne 0 ]; then
  echo "An error occured while creating the change set: $?". Exiting
  exit 2;
fi

CHANGESET_ID=$(echo "$CHANGESET" | jq -r '.Id')
STACK_ID=$(echo "$CHANGESET" | jq -r '.StackId')

echo "Changeset created with ARN ${CHANGESET_ID} on stack ${STACK_ID}"
echo "STACK_ID=${STACK_ID}" >> "$GITHUB_OUTPUT"
echo "CHANGESET_ID=${CHANGESET_ID}" >> "$GITHUB_OUTPUT"
echo "CHANGESET_URL=https://${AWS_REGION}.console.aws.amazon.com/cloudformation/home?region=${AWS_REGION}#/stacks/changesets/changes?stackId=${STACK_ID}&changeSetId=${CHANGESET_ID}" >> "$GITHUB_OUTPUT"
echo "Setting values CHANGESET_ID, STACK_ID, CHANGESET_URL on GITHUB_OUTPUT."

echo "Success. Exiting."
exit 0;