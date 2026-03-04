# ECR Push Guide — Developer Setup

Steps to push the retail store images to Amazon ECR from scratch.

---

## Step 1 — Configure AWS CLI

```bash
aws configure
```

You will be prompted for:
- `AWS Access Key ID`
- `AWS Secret Access Key`
- `Default region`: `us-east-1`
- `Default output format`: `json`

Verify it works:

```bash
aws sts get-caller-identity
```

Note your `Account` value — you will need it in the next steps.

---

## Step 2 — Create ECR repositories (one-time)

```bash
for repo in retail-store-ui retail-store-catalog retail-store-cart retail-store-checkout retail-store-orders; do
  aws ecr create-repository \
    --repository-name $repo \
    --region us-east-1
done
```

---

## Step 3 — Authenticate Docker with ECR

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

Expected output: `Login Succeeded`

---

## Step 4 — Tag images for ECR

```bash
ECR="<AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com"
VERSION="1.0.0"
DOCKER_USER="gheinz"

docker tag $DOCKER_USER/retail-store-ui:$VERSION        $ECR/retail-store-ui:$VERSION
docker tag $DOCKER_USER/retail-store-catalog:$VERSION   $ECR/retail-store-catalog:$VERSION
docker tag $DOCKER_USER/retail-store-cart:$VERSION      $ECR/retail-store-cart:$VERSION
docker tag $DOCKER_USER/retail-store-checkout:$VERSION  $ECR/retail-store-checkout:$VERSION
docker tag $DOCKER_USER/retail-store-orders:$VERSION    $ECR/retail-store-orders:$VERSION
```

Verify tags:

```bash
docker images | grep retail-store
```

---

## Step 5 — Push to ECR

```bash
docker push $ECR/retail-store-ui:$VERSION
docker push $ECR/retail-store-catalog:$VERSION
docker push $ECR/retail-store-cart:$VERSION
docker push $ECR/retail-store-checkout:$VERSION
docker push $ECR/retail-store-orders:$VERSION
```

---

## Step 6 — Verify

```bash
aws ecr list-images --repository-name retail-store-ui --region us-east-1
```

Or check in the AWS Console: **ECR → Repositories**.
