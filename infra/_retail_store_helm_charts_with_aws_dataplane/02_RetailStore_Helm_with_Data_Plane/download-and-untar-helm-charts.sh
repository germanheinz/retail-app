#!/bin/bash

set -e
echo "--------------------------------------------"
echo "Authenticating to Amazon Public ECR for Helm..."
echo "--------------------------------------------"

# Authenticate to Amazon Public ECR (token valid for 12 hours)
aws ecr-public get-login-password --region us-east-1 | \
helm registry login -u AWS --password-stdin public.ecr.aws

echo
echo "--------------------------------------------"
echo "Downloading & Extracting Helm Charts for Retail Store App"
echo "--------------------------------------------"

# Create charts directory
mkdir -p charts_base
cd charts_base

# Common variables
VERSION="1.0.1"
REGISTRY="oci://public.ecr.aws/i5b4r2o0"

# Step 01 - Catalog
echo "Downloading & Extracting Catalog Chart..."
helm pull $REGISTRY/retail-store-catalog-chart --version $VERSION --untar --untardir .

# Step 02 - Cart
echo "Downloading & Extracting Cart Chart..."
helm pull $REGISTRY/retail-store-cart-chart --version $VERSION --untar --untardir .

# Step 03 - Checkout
echo "Downloading & Extracting Checkout Chart..."
helm pull $REGISTRY/retail-store-checkout-chart --version $VERSION --untar --untardir .

# Step 04 - Orders
echo "Downloading & Extracting Orders Chart..."
helm pull $REGISTRY/retail-store-orders-chart --version $VERSION --untar --untardir .

# Step 05 - UI
echo "Downloading & Extracting UI Chart..."
helm pull $REGISTRY/retail-store-ui-chart --version $VERSION --untar --untardir .

echo
echo "✅ All charts downloaded and extracted successfully into ./charts directory"
echo "--------------------------------------------"
tree -L 2 || ls -1
