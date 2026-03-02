#!/bin/bash

# ================================================================
# Script to Build ALL Docker Images v1.3.0
# ================================================================

# ⚠️  CONFIGURATION - EDIT THESE VALUES
export DOCKER_USER="your_dockerhub_username"  # CHANGE HERE ⚠️
export VERSION="1.3.0-custom"
export BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
log_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  $1"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_step() {
    echo -e "\n${CYAN}▸${NC} $1"
}

# Banner
clear
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                                                          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}       🐳 RETAIL STORE IMAGE BUILDER v1.3.0            ${CYAN}║${NC}"
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

# Show configuration
log_header "CONFIGURATION"
echo ""
log_info "📁 Base Directory:  $BASE_DIR"
log_info "🐳 Docker User:     $DOCKER_USER"
log_info "🏷️  Version Tag:     $VERSION"
echo ""

# Verify Docker
log_step "Verifying Docker..."
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed"
    log_info "Install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

DOCKER_VERSION=$(docker --version)
log_success "Docker found: $DOCKER_VERSION"

# Verify Docker is running
if ! docker ps &> /dev/null; then
    log_error "Docker is not running"
    log_info "Start Docker Desktop and try again"
    exit 1
fi

log_success "Docker daemon is running"

# Verify src directory
if [ ! -d "$BASE_DIR/src" ]; then
    log_error "src/ directory not found"
    log_info "Make sure you're in the correct folder"
    exit 1
fi

log_success "src/ directory verified"
echo ""

# Array of services with description
declare -A SERVICES=(
    ["ui"]="Frontend Web (Java Spring Boot)"
    ["catalog"]="Product Catalog API (Go)"
    ["cart"]="Shopping Cart API (Java Spring Boot)"
    ["checkout"]="Checkout Process API (Node.js NestJS)"
    ["orders"]="Order Management API (Java Spring Boot)"
)

# Estimated times (in minutes)
declare -A BUILD_TIMES=(
    ["ui"]="10-15"
    ["catalog"]="5-8"
    ["cart"]="10-15"
    ["checkout"]="5-8"
    ["orders"]="10-15"
)

# Function to build image
build_image() {
    local SERVICE=$1
    local DESCRIPTION=$2
    local ESTIMATED_TIME=$3

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_header "BUILDING: $SERVICE"
    echo ""
    log_info "📦 Service:        $SERVICE"
    log_info "📝 Description:    $DESCRIPTION"
    log_info "⏱️  Estimated time: ~${ESTIMATED_TIME} minutes"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    cd "$BASE_DIR/src/$SERVICE" || {
        log_error "Could not access $BASE_DIR/src/$SERVICE"
        return 1
    }

    # Verify Dockerfile
    if [ ! -f "Dockerfile" ]; then
        log_error "Dockerfile not found in $SERVICE"
        return 1
    fi

    log_success "Dockerfile found"

    # Image names
    IMAGE_NAME="${DOCKER_USER}/retail-store-${SERVICE}:${VERSION}"
    IMAGE_LATEST="${DOCKER_USER}/retail-store-${SERVICE}:latest"

    log_info "🏷️  Main tag:     $IMAGE_NAME"
    log_info "🏷️  Latest tag:   $IMAGE_LATEST"
    echo ""

    # Start time
    START_TIME=$(date +%s)

    log_step "Starting build of $SERVICE..."
    echo ""

    # Build with progress
    if DOCKER_BUILDKIT=1 docker build \
        --progress=plain \
        -t "$IMAGE_NAME" \
        -t "$IMAGE_LATEST" \
        . 2>&1 | tee "/tmp/build-${SERVICE}.log"; then

        END_TIME=$(date +%s)
        ELAPSED=$((END_TIME - START_TIME))
        MINUTES=$((ELAPSED / 60))
        SECONDS=$((ELAPSED % 60))

        echo ""
        log_success "✅ $SERVICE built successfully"
        log_info "⏱️  Build time: ${MINUTES}m ${SECONDS}s"

        # Show image size
        IMAGE_SIZE=$(docker images "$IMAGE_NAME" --format "{{.Size}}" | head -1)
        log_info "💾 Size: $IMAGE_SIZE"

        echo ""
        return 0
    else
        log_error "❌ Error building $SERVICE"
        log_warning "Check log at: /tmp/build-${SERVICE}.log"
        echo ""
        return 1
    fi
}

# Initial summary
log_header "BUILD PLAN"
echo ""
log_info "Will build ${#SERVICES[@]} microservices:"
echo ""

TOTAL_MIN=0
TOTAL_MAX=0

for SERVICE in "${!SERVICES[@]}"; do
    TIME_RANGE="${BUILD_TIMES[$SERVICE]}"
    MIN_TIME=$(echo $TIME_RANGE | cut -d'-' -f1)
    MAX_TIME=$(echo $TIME_RANGE | cut -d'-' -f2)
    TOTAL_MIN=$((TOTAL_MIN + MIN_TIME))
    TOTAL_MAX=$((TOTAL_MAX + MAX_TIME))

    echo -e "  ${GREEN}✓${NC} $SERVICE - ${SERVICES[$SERVICE]}"
    echo -e "    └─ Estimated time: ~${TIME_RANGE} minutes"
done

echo ""
log_info "⏱️  Total estimated time: ${TOTAL_MIN}-${TOTAL_MAX} minutes"
echo ""

# Confirm start
read -p "$(echo -e ${YELLOW}Do you want to continue? [Y/n]: ${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    log_warning "Build cancelled by user"
    exit 0
fi

# Start total time
TOTAL_START=$(date +%s)

# Counters
SUCCESS_COUNT=0
FAIL_COUNT=0
declare -A FAILED_SERVICES

# Build all images
for SERVICE in "${!SERVICES[@]}"; do
    if build_image "$SERVICE" "${SERVICES[$SERVICE]}" "${BUILD_TIMES[$SERVICE]}"; then
        ((SUCCESS_COUNT++))
    else
        ((FAIL_COUNT++))
        FAILED_SERVICES[$SERVICE]=1
    fi
done

# Total time
TOTAL_END=$(date +%s)
TOTAL_ELAPSED=$((TOTAL_END - TOTAL_START))
TOTAL_MINUTES=$((TOTAL_ELAPSED / 60))
TOTAL_SECONDS=$((TOTAL_ELAPSED % 60))

# Final summary
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
log_header "FINAL BUILD SUMMARY"
echo ""

log_info "⏱️  Total time: ${TOTAL_MINUTES}m ${TOTAL_SECONDS}s"
log_info "📦 Total services: ${#SERVICES[@]}"
echo -e "  ${GREEN}✓ Successful:${NC}  $SUCCESS_COUNT"
echo -e "  ${RED}✗ Failed:${NC}      $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    log_success "🎉 All images built successfully!"
    echo ""
    log_header "CREATED IMAGES"
    echo ""
    docker images | grep "$DOCKER_USER/retail-store" | head -10
    echo ""
    log_header "NEXT STEP"
    echo ""
    log_info "To test locally:"
    echo -e "  ${CYAN}docker compose up${NC}"
    echo ""
    log_info "To push to Docker Hub:"
    echo -e "  ${CYAN}./push-to-dockerhub.sh${NC}"
    echo ""
else
    log_warning "⚠️  Some services failed:"
    echo ""
    for SERVICE in "${!FAILED_SERVICES[@]}"; do
        echo -e "  ${RED}✗${NC} $SERVICE"
        echo -e "    └─ Log: /tmp/build-${SERVICE}.log"
    done
    echo ""
    log_info "Check the logs above for more details"
    echo ""
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Exit code based on success/failure
if [ $FAIL_COUNT -eq 0 ]; then
    exit 0
else
    exit 1
fi
