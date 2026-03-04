# ECR Public Push Guide — Developer Setup

Steps to push the retail store images to Amazon ECR Public from scratch.

> ECR Public is free (50 GB storage + 500 GB transfer/month) and does not require credentials to pull.

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

---

## Step 2 — Get your ECR Public alias

```bash
aws ecr-public describe-registries --region us-east-1 \
  --query "registries[0].aliases[0].name" --output text
```

You will get something like `xxxxxxxx`. Use this as your `<ALIAS>` in the steps below.

---

## Step 3 — Authenticate Docker with ECR Public

```bash
aws ecr-public get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin public.ecr.aws
```

Expected output: `Login Succeeded`

---

## Step 4 — Create the ECR Public repositories (one-time)

```bash
for repo in retail-store-ui retail-store-catalog retail-store-cart retail-store-checkout retail-store-orders; do
  aws ecr-public create-repository \
    --repository-name $repo \
    --region us-east-1
done
```

---

## Step 5 — Tag images for ECR Public

```bash
GALLERY="public.ecr.aws/<ALIAS>"
VERSION="1.0.0"
DOCKER_USER="gheinz"

docker tag $DOCKER_USER/retail-store-ui:$VERSION        $GALLERY/retail-store-ui:$VERSION
docker tag $DOCKER_USER/retail-store-catalog:$VERSION   $GALLERY/retail-store-catalog:$VERSION
docker tag $DOCKER_USER/retail-store-cart:$VERSION      $GALLERY/retail-store-cart:$VERSION
docker tag $DOCKER_USER/retail-store-checkout:$VERSION  $GALLERY/retail-store-checkout:$VERSION
docker tag $DOCKER_USER/retail-store-orders:$VERSION    $GALLERY/retail-store-orders:$VERSION
```

Verify tags:

```bash
docker images | grep retail-store
```

---

## Step 6 — Push to ECR Public

```bash
docker push $GALLERY/retail-store-ui:$VERSION
docker push $GALLERY/retail-store-catalog:$VERSION
docker push $GALLERY/retail-store-cart:$VERSION
docker push $GALLERY/retail-store-checkout:$VERSION
docker push $GALLERY/retail-store-orders:$VERSION
```

---

## Step 7 — Verify

```bash
aws ecr-public describe-images \
  --repository-name retail-store-ui \
  --region us-east-1
```

Or check in the AWS Console: **ECR Public → Repositories** or at [gallery.ecr.aws](https://gallery.ecr.aws).

---

## Cleanup — Delete private ECR repositories

If you had private repos before, delete them to avoid storage costs:

```bash
for repo in retail-store-ui retail-store-catalog retail-store-cart retail-store-checkout retail-store-orders; do
  aws ecr delete-repository \
    --repository-name $repo \
    --region us-east-1 \
    --force
done
```
