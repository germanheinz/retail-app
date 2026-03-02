# 🚀 QUICK START - 3 Simple Steps

Want to build your own Docker images NOW? Follow these 3 steps:

---

## ⚡ STEP 1: Configure Username (2 minutes)

### 1.1 Create Docker Hub account (if you don't have one)
- Go to: **https://hub.docker.com/signup**
- Create your account (FREE)
- Write down your **username**

### 1.2 Edit scripts with your username

**File:** `build-all-images.sh` (line 7)
```bash
# BEFORE:
export DOCKER_USER="your_dockerhub_username"

# AFTER (example):
export DOCKER_USER="johnsmith"
```

**File:** `push-to-dockerhub.sh` (line 7)
```bash
# BEFORE:
export DOCKER_USER="your_dockerhub_username"

# AFTER (example):
export DOCKER_USER="johnsmith"
```

---

## 🏗️ STEP 2: Build Images (30-60 min)

```bash
# Grant execution permissions
chmod +x build-all-images.sh
chmod +x push-to-dockerhub.sh

# Run build
./build-all-images.sh

# ☕ Go grab a coffee while it compiles
#    (First time: 30-60 minutes)
```

### What does this command do?
- ✅ Builds UI (Java Spring Boot)
- ✅ Builds Catalog (Go)
- ✅ Builds Cart (Java Spring Boot)
- ✅ Builds Checkout (Node.js)
- ✅ Builds Orders (Java Spring Boot)

### Approximate times:
```
UI:       ~15 min ☕
Catalog:  ~8 min
Cart:     ~15 min ☕
Checkout: ~8 min
Orders:   ~15 min ☕
────────────────────
TOTAL:    ~60 min
```

---

## 📤 STEP 3: Push to Docker Hub (5-10 min)

```bash
# Run push
./push-to-dockerhub.sh

# You'll be asked for your Docker Hub password
# (Or use a Personal Access Token)
```

### Result:
```
✅ 5 services × 2 tags = 10 images on Docker Hub
✅ Ready to use in Kubernetes
✅ Accessible from anywhere
```

---

## ✅ VERIFY

### View local images:
```bash
docker images | grep retail-store
```

### View on Docker Hub:
```
https://hub.docker.com/u/YOUR_USERNAME
```

---

## 🎨 BONUS: Customization (Optional)

If you want to make changes before building:

### Simple Change - Store Title

```bash
cd src/ui/src/main/resources

# Find messages.properties file
# Change:
application.title=Retail Store Sample

# To:
application.title=My DevOps Store by John Smith
```

Then rebuild only UI:
```bash
cd src/ui
docker build -t YOUR_USER/retail-store-ui:1.3.0-custom-v2 .
docker push YOUR_USER/retail-store-ui:1.3.0-custom-v2
```

---

## 🔄 What's Next?

### Option 1: Test Locally (Section 04)
```bash
# Edit docker-compose.yaml
# Change images to yours

DB_PASSWORD='pass123' docker compose up

# Access in browser
http://localhost:8888
```

### Option 2: Use in Kubernetes (Sections 08-13)
```yaml
# In your Kubernetes manifests:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: catalog
spec:
  template:
    spec:
      containers:
      - name: catalog
        image: YOUR_USER/retail-store-catalog:1.3.0-custom
        # Instead of:
        # image: public.ecr.aws/aws-containers/retail-store-sample-catalog:1.3.0
```

### Option 3: Migrate to ECR (Section 14)
```bash
# Configure AWS CLI
aws configure

# Migrate images
./migrate-to-ecr.sh
```

---

## ❓ Quick Troubleshooting

### Error: "Docker daemon not running"
```bash
# Start Docker Desktop
# Windows: Open Docker Desktop from start menu
```

### Error: Build very slow
```bash
# It's NORMAL on first build
# Docker caches layers
# Subsequent builds will be FASTER (5-10 min)
```

### Error: "No space left on device"
```bash
# Clean Docker
docker system prune -a

# Check space
df -h  # Linux/Mac
# Or check disk properties on Windows
```

### Error on Docker Hub Login
```bash
# Use Personal Access Token instead of password
# Create token at: https://hub.docker.com/settings/security
```

---

## 📊 Reference Sizes

```
retail-store-ui:       ~280 MB
retail-store-catalog:  ~180 MB
retail-store-cart:     ~280 MB
retail-store-checkout: ~220 MB
retail-store-orders:   ~280 MB
─────────────────────────────────
TOTAL:                ~1.24 GB
```

**On Docker Hub:** Unlimited space (public repos) ✅

---

## 🎯 Progress Checklist

- [ ] Create Docker Hub account
- [ ] Edit `build-all-images.sh` with your username
- [ ] Edit `push-to-dockerhub.sh` with your username
- [ ] Run `./build-all-images.sh`
- [ ] ☕ Have coffee while it compiles
- [ ] Run `./push-to-dockerhub.sh`
- [ ] Verify at https://hub.docker.com/u/YOUR_USER
- [ ] Use images in course (sections 8-14)

---

## 💡 Tips

### Faster Build
```bash
# Use BuildKit for better performance
export DOCKER_BUILDKIT=1
./build-all-images.sh
```

### Build Only One Service
```bash
cd src/ui  # Or catalog, cart, checkout, orders

# Manual build
docker build -t YOUR_USER/retail-store-ui:1.3.0-custom .

# Manual push
docker push YOUR_USER/retail-store-ui:1.3.0-custom
```

### View Build Progress
```bash
# Logs are saved in /tmp/
tail -f /tmp/build-ui.log
tail -f /tmp/build-catalog.log
# etc...
```

---

## 📚 Complete Documentation

For more details, see: **[README.md](README.md)**

---

## 🎉 Ready!

With these 3 steps you'll have your own custom Docker images.

**Next command:** `./build-all-images.sh`

🚀 **Let's build!**
