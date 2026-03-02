#!/bin/bash

# ================================================================
# Script to Push Images to Docker Hub
# ================================================================

# ⚠️  CONFIGURATION - EDIT THESE VALUES
export DOCKER_USER="your_dockerhub_username"  # CHANGE HERE ⚠️
export VERSION="1.3.0-custom"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  $1"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
}

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_step() { echo -e "\n${CYAN}▸${NC} $1"; }

# Banner
clear
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                                                          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}       ⬆️  PUSH TO DOCKER HUB v1.3.0                    ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                          ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verify configuration
if [ "$DOCKER_USER" == "your_dockerhub_username" ]; then
    log_error "⚠️  Please configure your DOCKER_USER in the script"
    echo ""
    log_info "Edit this file and change line 7:"
    echo -e "  ${YELLOW}export DOCKER_USER=\"your_dockerhub_username\"${NC}"
    echo ""
    exit 1
fi

# Configuration
log_header "CONFIGURATION"
echo ""
log_info "🐳 Docker User: $DOCKER_USER"
log_info "🏷️  Version:     $VERSION"
echo ""

# Verify Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed"
    exit 1
fi

log_success "Docker found"

# Array of services
SERVICES=("ui" "catalog" "cart" "checkout" "orders")

# Verify images exist locally
log_step "Verifying local images..."
echo ""

MISSING=0
for SERVICE in "${SERVICES[@]}"; do
    IMAGE_NAME="${DOCKER_USER}/retail-store-${SERVICE}:${VERSION}"

    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${IMAGE_NAME}$"; then
        log_success "✅ Found: $SERVICE"
    else
        log_error "❌ Not found: $SERVICE"
        ((MISSING++))
    fi
done

if [ $MISSING -gt 0 ]; then
    echo ""
    log_error "$MISSING images not found"
    log_warning "Run first: ./build-all-images.sh"
    exit 1
fi

log_success "All images found locally"
echo ""

# Login to Docker Hub
log_header "LOGIN TO DOCKER HUB"
echo ""
log_info "Starting login..."
echo ""

if ! docker login -u "$DOCKER_USER"; then
    log_error "Login failed"
    echo ""
    log_info "If you don't have an account, create one at: https://hub.docker.com/signup"
    exit 1
fi

echo ""
log_success "✅ Login successful to Docker Hub"
echo ""

# Confirm push
log_header "PUSH PLAN"
echo ""
log_info "Will push ${#SERVICES[@]} services × 2 tags = $((${#SERVICES[@]} * 2)) images"
echo ""

for SERVICE in "${SERVICES[@]}"; do
    echo -e "  ${GREEN}✓${NC} $SERVICE"
    echo -e "    ├─ ${DOCKER_USER}/retail-store-${SERVICE}:${VERSION}"
    echo -e "    └─ ${DOCKER_USER}/retail-store-${SERVICE}:latest"
done

echo ""
read -p "$(echo -e ${YELLOW}Do you want to continue? [Y/n]: ${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    log_warning "Push cancelled by user"
    exit 0
fi

# Counters
SUCCESS_COUNT=0
FAIL_COUNT=0
START_TIME=$(date +%s)

# Push images
for SERVICE in "${SERVICES[@]}"; do
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_header "PUSHING: $SERVICE"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    IMAGE_VERSION="${DOCKER_USER}/retail-store-${SERVICE}:${VERSION}"
    IMAGE_LATEST="${DOCKER_USER}/retail-store-${SERVICE}:latest"

    # Push specific version
    echo ""
    log_step "Pushing: $IMAGE_VERSION"

    if docker push "$IMAGE_VERSION"; then
        log_success "✅ Pushed: $IMAGE_VERSION"
    else
        log_error "❌ Error pushing $IMAGE_VERSION"
        ((FAIL_COUNT++))
        continue
    fi

    # Push latest
    echo ""
    log_step "Pushing: $IMAGE_LATEST"

    if docker push "$IMAGE_LATEST"; then
        log_success "✅ Pushed: $IMAGE_LATEST"
        ((SUCCESS_COUNT++))
    else
        log_error "❌ Error pushing $IMAGE_LATEST"
        ((FAIL_COUNT++))
        continue
    fi

    echo ""
    log_success "✅ $SERVICE pushed completely"
    log_info "📍 URL: https://hub.docker.com/r/${DOCKER_USER}/retail-store-${SERVICE}"
done

# Total time
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

# Final summary
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
log_header "PUSH SUMMARY"
echo ""

log_info "⏱️  Total time: ${MINUTES}m ${SECONDS}s"
log_info "📦 Total services: ${#SERVICES[@]}"
echo -e "  ${GREEN}✓ Successful:${NC} $SUCCESS_COUNT"
echo -e "  ${RED}✗ Failed:${NC}     $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    log_success "🎉 All images pushed successfully!"
    echo ""
    log_header "NEXT STEP"
    echo ""
    log_info "🌐 Verify your images at:"
    echo -e "   ${CYAN}https://hub.docker.com/u/${DOCKER_USER}${NC}"
    echo ""
    log_info "📝 To use in Kubernetes, update images to:"
    echo ""
    for SERVICE in "${SERVICES[@]}"; do
        echo -e "   ${GREEN}image:${NC} ${DOCKER_USER}/retail-store-${SERVICE}:${VERSION}"
    done
    echo ""
    log_info "💡 Optional: Migrate to Amazon ECR"
    echo -e "   ${CYAN}./migrate-to-ecr.sh${NC}"
    echo ""
else
    log_warning "⚠️  Some services failed"
    log_info "Check errors above and try again"
    echo ""
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Exit code
if [ $FAIL_COUNT -eq 0 ]; then
    exit 0
else
    exit 1
fi
