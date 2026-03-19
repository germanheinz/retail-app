#!/bin/bash
set -e

echo "============================================================"
echo "STEP-3: Create RetailStore AWS Dataplane using Terraform"
echo "============================================================"
cd 02_retailstore_values_HELM_aws_dataplane/02_retailstore_values_HELM_aws_dataplane
terraform init 
terraform apply -auto-approve

echo
echo "RetailStore AWS Dataplance (RDS MySQL, RDS PostgreSQL, Elasticcache, SQS) creation completed successfully!"
