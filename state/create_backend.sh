#!/bin/bash
PROJECT_NAME="${PWD##*/}"
AWS_REGION="us-east-1"

if ( aws dynamodb describe-table --table-name terraform_locks --region $AWS_REGION > /dev/null 2>&1 ); then
  echo "DynamoDB table already exists.  Skipping creation."
else
  aws dynamodb create-table \
	--region $AWS_REGION \
	--table-name terraform_locks \
	--attribute-definitions AttributeName=LockID,AttributeType=S \
	--key-schema AttributeName=LockID,KeyType=HASH \
	--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
fi

cat <<EOF > ./_backend.tf
terraform {
  backend "s3" {
    bucket         = "${ORG}-tf-state-store"
    region         = "${AWS_REGION}"
    key            = "${PROJECT_NAME}/terraform.tfstate"
    dynamodb_table = "terraform_locks"
  }
}
EOF
