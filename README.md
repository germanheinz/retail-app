# Retail Store Sample App — Custom Build v1.0.0

A customized build of the [AWS Containers Retail Store Sample App](https://github.com/aws-containers/retail-store-sample-app) (v1.0.0), containerized as independent microservices and ready to deploy with Docker Compose or Kubernetes.

---

## Project Structure

```
retail-store-v1.0.0/
├── README.md                    # This file
├── docker-compose.yaml          # Run the full stack locally
├── docker-compose.build.yaml    # Build all custom images
├── kubernetes.yaml              # Kubernetes manifests
├── samples/
│   ├── data/                    # Product JSON data
│   └── images/                  # Product images
└── src/
    ├── ui/                      # Frontend — Java Spring Boot
    ├── catalog/                 # Catalog API — Go
    ├── cart/                    # Cart API — Java Spring Boot
    ├── checkout/                # Checkout API — Node.js (NestJS)
    └── orders/                  # Orders API — Java Spring Boot
```

---

## Prerequisites

| Tool | Version | Required |
|------|---------|----------|
| Docker Desktop / Docker Engine | 20.10+ | Yes |
| Docker Compose | v2.0+ | Yes |
| Docker Hub account | — | Yes (for push) |
| AWS CLI | v2.x+ | No (ECR only) |

Verify your setup:

```bash
docker --version
docker compose version
aws --version   # optional
```

---

## Services

| Service | Language | Internal Port | Description |
|---------|----------|---------------|-------------|
| `ui` | Java Spring Boot | 8080 | Web frontend (exposed on 8888) |
| `catalog` | Go | 8080 | Product catalog API + MariaDB |
| `cart` | Java Spring Boot | 8080 | Shopping cart API + DynamoDB Local |
| `checkout` | Node.js NestJS | 8080 | Checkout flow API + Redis |
| `orders` | Java Spring Boot | 8080 | Order management API + PostgreSQL + RabbitMQ |

---

## Quick Start

### Option A — Run with pre-built images (no build required)

Pull images directly from Amazon ECR Public and start the stack:

```bash
DB_PASSWORD='yourpassword' docker compose up
```

Access the store at [http://localhost:8888](http://localhost:8888).

To stop:

```bash
docker compose down
```

---

### Option B — Build your own images

**Step 1 — Set your Docker Hub username and target version:**

```bash
export DOCKER_USER="your_dockerhub_username"
export VERSION="1.3.0-custom"
```

**Step 2 — Build all images:**

```bash
docker compose -f docker-compose.build.yaml build
```

Build a single service:

```bash
docker compose -f docker-compose.build.yaml build ui
```

Build without cache:

```bash
docker compose -f docker-compose.build.yaml build --no-cache
```

> First build takes 30–60 minutes. Subsequent builds use layer cache and are significantly faster.

**Step 3 — Push to Docker Hub:**

```bash
docker login
docker compose -f docker-compose.build.yaml push
```

**Step 4 — Update `docker-compose.yaml` to use your images:**

Replace the `image:` values in `docker-compose.yaml`:

```yaml
# Before
image: public.ecr.aws/aws-containers/retail-store-sample-ui:1.3.0

# After
image: your_dockerhub_username/retail-store-ui:1.3.0-custom
```

**Step 5 — Run with your custom images:**

```bash
DB_PASSWORD='yourpassword' docker compose up
```

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DB_PASSWORD` | Yes | Shared password for MySQL, PostgreSQL, and RabbitMQ |
| `DOCKER_USER` | Build only | Your Docker Hub username |
| `VERSION` | Build only | Image tag (default: `1.3.0-custom`) |
| `RETAIL_UI_THEME` | No | UI color theme (`default`, `orange`, `blue`, `green`, `teal`) |

---

## UI Customization

### Change the application title

```
src/ui/src/main/resources/messages.properties
```

```properties
# Find this line and update it:
application.title=My Retail Store
```

### Change the UI theme

Add the environment variable to `ui` in `docker-compose.yaml`:

```yaml
environment:
  - RETAIL_UI_THEME=teal
```

Available themes: `default`, `orange`, `blue`, `green`, `teal`

---

## Kubernetes Deployment

Apply the manifests to your cluster:

```bash
kubectl apply -f kubernetes.yaml
```

To use your custom images, replace the ECR Public image references in `kubernetes.yaml` with your Docker Hub images before applying.

---

## Migrate to Amazon ECR

After pushing to Docker Hub, you can re-tag and push to ECR:

```bash
aws configure

# Authenticate Docker with ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    123456789.dkr.ecr.us-east-1.amazonaws.com

# Tag and push
docker tag your_user/retail-store-ui:1.3.0-custom \
  123456789.dkr.ecr.us-east-1.amazonaws.com/retail-store-ui:1.3.0-custom

docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/retail-store-ui:1.3.0-custom
```

---

## Useful Docker Commands

```bash
# List all retail-store images
docker images | grep retail-store

# View service logs
docker compose logs -f ui

# Access a running container
docker exec -it <container_id> /bin/sh

# Remove all retail-store images
docker images | grep retail-store | awk '{print $3}' | xargs docker rmi -f

# Free up disk space
docker system prune -a --volumes
```

---

## Troubleshooting

**Build is slow**
The first build compiles Java and downloads Go/Node.js dependencies. This is expected. Enable BuildKit for faster builds:
```bash
export DOCKER_BUILDKIT=1
```

**"No space left on device"**
```bash
docker system prune -a --volumes
df -h
```

**Java build fails (ui, cart, orders)**
Ensure Docker Desktop has at least 4 GB of memory allocated (Settings → Resources → Memory).
```bash
cd src/ui
./mvnw clean package -DskipTests
```

**Go build fails (catalog)**
```bash
cd src/catalog
go mod download && go mod verify
go build -o catalog
```

**Node.js build fails (checkout)**
```bash
cd src/checkout
rm -rf node_modules package-lock.json
npm install && npm run build
```

---

## Image Sizes (approximate)

| Image | Size |
|-------|------|
| `retail-store-ui` | ~280 MB |
| `retail-store-catalog` | ~180 MB |
| `retail-store-cart` | ~280 MB |
| `retail-store-checkout` | ~220 MB |
| `retail-store-orders` | ~280 MB |
| **Total** | **~1.24 GB** |

---

## References

- [Upstream project — aws-containers/retail-store-sample-app](https://github.com/aws-containers/retail-store-sample-app)
- [Docker Hub](https://hub.docker.com)
- [Amazon ECR](https://aws.amazon.com/ecr/)
- [Amazon ECR Public Gallery](https://gallery.ecr.aws/aws-containers)

---

## License

Based on the [AWS Containers Retail Store Sample App](https://github.com/aws-containers/retail-store-sample-app), licensed under MIT.
Custom modifications are your own.
