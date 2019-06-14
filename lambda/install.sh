#!/bin/bash

DIGITS_RE='^[0-9]+$'
TEMPLATE_FILE_NAME='cloudformation.yml'
PACKAGE_FILE_NAME='serverless-xfm.yml'
STACK_NAME='ServerlessExpressStack'
STAGE_NAME='API'
LAMBDA_NAME='ServerlessExpress'

# Check if the aws cli is installed
if ! command -v aws > /dev/null; then
    echo "aws cli was not found. Please install before running this script."
    exit 1
fi

ACCOUNT_ID=`aws sts get-caller-identity --query 'Account' --output=text --profile khalid`
REGION=`aws configure get region --profile khalid`
BUCKET_NAME="${ACCOUNT_ID}-${REGION}-serverless-express"

NODE_DONE=`node scripts/configure.js --account-id ${ACCOUNT_ID} --region ${REGION} --function-name ${LAMBDA_NAME}`

# Check if the account id is valid
if ! [[ ${ACCOUNT_ID} =~ ${DIGITS_RE} ]] ; then
   echo "Invalid account ID" >&2
   exit 1
fi

# Check if the bucket already exists
BUCKETS_EXISTS=`aws s3 ls --profile khalid | grep ${BUCKET_NAME}`

if [ ! -z "${BUCKETS_EXISTS}" -a "${BUCKETS_EXISTS}" != " " ]; then
        echo "Bucket ${BUCKET_NAME} already exists."
        # echo "https://console.aws.amazon.com/s3/home"
        # exit 1
        # Try to create the bucket
else 
    if aws s3 mb s3://${BUCKET_NAME} --profile khalid; then
        echo "Bucket s3://${BUCKET_NAME} created successfully"
    else
        echo "Failed creating bucket s3://${BUCKET_NAME}"
        exit 1
    fi
fi


# Try to create CloudFormation package
if aws cloudformation package --template-file ${TEMPLATE_FILE_NAME} --output-template-file ${PACKAGE_FILE_NAME} --s3-bucket ${BUCKET_NAME} --profile khalid; then
    echo "CloudFormation successfully created the package ${PACKAGE_FILE_NAME}"
else
    echo "Failed creating CloudFormation package"
    exit 1
fi

# Try to deploy the package
if aws cloudformation deploy --template-file ${PACKAGE_FILE_NAME} --stack-name ${STACK_NAME} --capabilities CAPABILITY_IAM --parameter-overrides StageName=${STAGE_NAME} --profile khalid; then
    echo "CloudFormation successfully deployed the serverless app package"
else
    echo "Failed deploying CloudFormation package"
    exit 1
fi
