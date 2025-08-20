#!/bin/bash
set -e

# Health Check Script for FastAPI Infrastructure
# Usage: ./curl-health.sh <environment>
# Example: ./curl-health.sh dev
#          ./curl-health.sh prod

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# Check arguments
ENV="$1"
VERBOSE="${2:-false}"

if [[ -z "$ENV" ]] || [[ ! "$ENV" =~ ^(dev|prod)$ ]]; then
    echo "Usage: $0 <dev|prod> [verbose]"
    echo ""
    echo "Examples:"
    echo "  $0 dev           # Check development environment health"
    echo "  $0 prod          # Check production environment health"
    echo "  $0 dev verbose   # Verbose output with detailed information"
    echo ""
    echo "Environment variables:"
    echo "  HEALTH_TIMEOUT   - Timeout for health checks in seconds (default: 30)"
    echo "  RETRY_COUNT      - Number of retries for failed checks (default: 3)"
    echo "  RETRY_DELAY      - Delay between retries in seconds (default: 5)"
    exit 1
fi

if [[ "$2" == "verbose" ]]; then
    VERBOSE="true"
fi

# Configuration
TIMEOUT="${HEALTH_TIMEOUT:-30}"
RETRY_COUNT="${RETRY_COUNT:-3}"
RETRY_DELAY="${RETRY_DELAY:-5}"

# Set directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="${SCRIPT_DIR}/../envs/$ENV"

if [[ ! -d "$ENV_DIR" ]]; then
    error "Environment directory not found: $ENV_DIR"
    exit 1
fi

cd "$ENV_DIR"

# Banner
echo "🏥 FastAPI Infrastructure Health Check"
echo "======================================"
echo "Environment: $ENV"
echo "Timeout: ${TIMEOUT}s"
echo "Retries: $RETRY_COUNT"
echo ""

# Get application URL from Terraform output
log "Retrieving application details from Terraform state..."

HEALTH_URL=""
APP_URL=""

if terraform output -raw health_check_url &>/dev/null; then
    HEALTH_URL=$(terraform output -raw health_check_url)
    debug "Health URL from Terraform: $HEALTH_URL"
fi

if terraform output -raw app_url &>/dev/null; then
    APP_URL=$(terraform output -raw app_url)
    debug "App URL from Terraform: $APP_URL"
fi

if [[ -z "$HEALTH_URL" ]] || [[ "$HEALTH_URL" == "null" ]]; then
    error "Could not get health check URL from Terraform output"
    echo "Make sure the $ENV environment is deployed and accessible"
    exit 1
fi

log "Health Check URL: $HEALTH_URL"

# Function to perform HTTP request with retries
perform_request() {
    local url="$1"
    local description="$2"
    local expected_status="${3:-200}"
    local content_check="$4"
    
    log "Testing $description..."
    debug "URL: $url"
    debug "Expected Status: $expected_status"
    
    for ((i=1; i<=RETRY_COUNT; i++)); do
        debug "Attempt $i of $RETRY_COUNT"
        
        # Perform HTTP request
        response=$(curl -s -w "\n%{http_code}\n%{time_total}\n" \
                       --max-time "$TIMEOUT" \
                       --connect-timeout 10 \
                       "$url" 2>/dev/null || echo -e "\nERROR\n0")
        
        # Parse response
        http_body=$(echo "$response" | head -n -2)
        http_code=$(echo "$response" | tail -n 2 | head -n 1)
        time_total=$(echo "$response" | tail -n 1)
        
        debug "HTTP Code: $http_code"
        debug "Response Time: ${time_total}s"
        
        if [[ "$http_code" == "$expected_status" ]]; then
            success "$description - HTTP $http_code (${time_total}s)"
            
            # Content validation if specified
            if [[ -n "$content_check" ]]; then
                if echo "$http_body" | grep -q "$content_check"; then
                    success "Content validation passed"
                else
                    warning "Content validation failed - '$content_check' not found"
                fi
            fi
            
            # Show response body if verbose
            if [[ "$VERBOSE" == "true" ]]; then
                echo "Response Body:"
                echo "$http_body" | jq . 2>/dev/null || echo "$http_body"
                echo ""
            fi
            
            return 0
        else
            warning "$description - HTTP $http_code (attempt $i/$RETRY_COUNT)"
            
            if [[ "$VERBOSE" == "true" ]] && [[ -n "$http_body" ]]; then
                echo "Response: $http_body"
            fi
            
            if [[ $i -lt $RETRY_COUNT ]]; then
                debug "Waiting ${RETRY_DELAY}s before retry..."
                sleep "$RETRY_DELAY"
            fi
        fi
    done
    
    error "$description failed after $RETRY_COUNT attempts"
    return 1
}

# Health check results
HEALTH_PASSED=0
TOTAL_CHECKS=0

# 1. Basic Health Check
log "=== Basic Health Check ==="
if perform_request "$HEALTH_URL" "Health Endpoint" "200" '"status"'; then
    ((HEALTH_PASSED++))
fi
((TOTAL_CHECKS++))

# 2. Root Endpoint Check
if [[ -n "$APP_URL" ]] && [[ "$APP_URL" != "null" ]]; then
    echo ""
    log "=== Root Endpoint Check ==="
    if perform_request "$APP_URL" "Root Endpoint" "200"; then
        ((HEALTH_PASSED++))
    fi
    ((TOTAL_CHECKS++))
    
    # 3. API Test Endpoint
    echo ""
    log "=== API Test Endpoint ==="
    if perform_request "$APP_URL/api/test" "API Test Endpoint" "200"; then
        ((HEALTH_PASSED++))
    fi
    ((TOTAL_CHECKS++))
fi

# 4. Documentation Endpoint (common FastAPI feature)
if [[ -n "$APP_URL" ]] && [[ "$APP_URL" != "null" ]]; then
    echo ""
    log "=== Documentation Check ==="
    if perform_request "$APP_URL/docs" "API Documentation" "200" "swagger"; then
        ((HEALTH_PASSED++))
    fi
    ((TOTAL_CHECKS++))
fi

# Summary
echo ""
echo "🔍 Health Check Summary"
echo "======================"
echo "Environment: $ENV"
echo "Checks Passed: $HEALTH_PASSED/$TOTAL_CHECKS"
echo "Health URL: $HEALTH_URL"

if [[ -n "$APP_URL" ]] && [[ "$APP_URL" != "null" ]]; then
    echo "App URL: $APP_URL"
fi

echo ""

if [[ $HEALTH_PASSED -eq $TOTAL_CHECKS ]]; then
    success "All health checks passed! 🎉"
    echo ""
    echo "✅ Application is healthy and accessible"
    echo "✅ All endpoints are responding correctly"
    
    if [[ "$VERBOSE" == "true" ]]; then
        echo ""
        log "Additional Information:"
        terraform output -raw deployment_summary 2>/dev/null | jq . 2>/dev/null || terraform output deployment_summary 2>/dev/null || true
    fi
    
    exit 0
else
    error "Some health checks failed! ❌"
    echo ""
    echo "❌ $((TOTAL_CHECKS - HEALTH_PASSED)) out of $TOTAL_CHECKS checks failed"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check if the EC2 instance is running: aws ec2 describe-instances"
    echo "2. SSH to the instance and check service status: make ssh-$ENV"
    echo "3. Check application logs: sudo journalctl -u fastapi-infra -f"
    echo "4. Verify security groups allow HTTP traffic on port 8000"
    echo "5. Check if the FastAPI service is listening: sudo netstat -tlnp | grep 8000"
    
    exit 1
fi