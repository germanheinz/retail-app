# Retail Store App v1.0.0

Retail store application containerized as independent microservices, ready to deploy with Docker Compose or Kubernetes.

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

**Step 1 — Pull the images from ECR Public:**

```bash
GALLERY="public.ecr.aws/<ALIAS>"
VERSION="1.0.0"

docker pull $GALLERY/retail-store-ui:$VERSION
docker pull $GALLERY/retail-store-catalog:$VERSION
docker pull $GALLERY/retail-store-cart:$VERSION
docker pull $GALLERY/retail-store-checkout:$VERSION
docker pull $GALLERY/retail-store-orders:$VERSION
```

> No login required — images are public. Replace `<ALIAS>` with the ECR Public alias.

**Step 3 — Run the stack:**

```bash
DB_PASSWORD='yourpassword' docker compose up
```

Access the store at [http://localhost:8888](http://localhost:8888).

To stop:

```bash
docker compose down
```

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DB_PASSWORD` | Yes | Shared password for MySQL, PostgreSQL, and RabbitMQ |
| `DOCKER_USER` | Build only | Your Docker Hub username (used in docker-compose.build.yaml) |
| `VERSION` | Build only | Image tag (default: `1.0.0`) |
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

To use your custom images, replace the image references in `kubernetes.yaml` with your ECR URIs before applying.

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

## For Developers

- [ECR Push Guide — push images from scratch](docs/ecr-push.md)

---

## References

- [Docker Hub](https://hub.docker.com)
- [Amazon ECR](https://aws.amazon.com/ecr/)
- [Amazon ECR Public Gallery](https://gallery.ecr.aws/aws-containers)

---

## License

MIT License.
