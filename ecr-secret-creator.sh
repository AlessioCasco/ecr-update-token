#!/bin/bash

# Get directory of script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $# -ne 5 ]]
then
    echo "ERROR: This script expects namsespance, credential file, credential profile, aws_account and aws_region to be given as an argument"
    echo "e.g. ./ecr-secret-creator.sh nginx-ingress ~/.aws/credentials prod-ecr 12345678912 eu-west-1"
    exit 1
fi

export NAMESPACE=$1
export CREDENTIAL_FILE=$2
export PROFILE=$3
export AWS_ACCOUNT=$4
export AWS_REGION=$5

# Steal the aws creds from the user's configuration for awscli
export AWS_ACCESS_KEY_ID=`grep -A 2 "$PROFILE" $CREDENTIAL_FILE | grep aws_access_key_id | head -1 | cut -d'=' -f2 | tr -d [:space:] | base64`
export AWS_SECRET_ACCESS_KEY=`grep -A 2 "$PROFILE" $CREDENTIAL_FILE | grep aws_secret_access_key | head -1 | cut -d'=' -f2 | tr -d [:space:] | base64`
if [ -z "$AWS_ACCESS_KEY_ID" ]
then
    echo "ERROR: Failed to work out the AWS_ACCESS_KEY_ID"
    exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]
then
    echo "ERROR: Failed to work out the AWS_SECRET_ACCESS_KEY"
    exit 1
fi

# Fill in the variables in the yaml and run kubectl
cat $DIR/templates/ecr-cred-updater.yaml | envsubst '$NAMESPACE $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $AWS_ACCOUNT $AWS_REGION' | kubectl apply -n ${1} -f -
