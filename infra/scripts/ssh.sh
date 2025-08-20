#!/bin/bash
set -e

# SSH into FastAPI Infrastructure EC2 instance
# Usage: ./ssh.sh <environment>
# Example: ./ssh.sh dev
#          ./ssh.sh prod

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Check arguments
ENV="$1"
if [[ -z "$ENV" ]] || [[ ! "$ENV" =~ ^(dev|prod)$ ]]; then
    echo "Usage: $0 <dev|prod>"
    echo ""
    echo "Examples:"
    echo "  $0 dev   # SSH to development instance"
    echo "  $0 prod  # SSH to production instance"
    echo ""
    echo "Environment variables:"
    echo "  SSH_KEY_PATH  - Path to SSH private key (default: ~/.ssh/id_rsa)"
    echo "  SSH_USER      - SSH username (default: ec2-user)"
    exit 1
fi

# Set directories and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="${SCRIPT_DIR}/../envs/$ENV"

if [[ ! -d "$ENV_DIR" ]]; then
    error "Environment directory not found: $ENV_DIR"
    exit 1
fi

cd "$ENV_DIR"

log "Connecting to $ENV environment EC2 instance..."

# Get connection details from Terraform output
log "Retrieving connection details from Terraform state..."

# Try to get public IP (preference for Elastic IP)
PUBLIC_IP=""
if terraform output -raw elastic_ip &>/dev/null && [[ -n "$(terraform output -raw elastic_ip)" ]]; then
    PUBLIC_IP=$(terraform output -raw elastic_ip)
    log "Using Elastic IP: $PUBLIC_IP"
elif terraform output -raw ec2_public_ip &>/dev/null; then
    PUBLIC_IP=$(terraform output -raw ec2_public_ip)
    log "Using EC2 public IP: $PUBLIC_IP"
else
    error "Could not get EC2 public IP from Terraform output"
    echo "Make sure the $ENV environment is deployed and accessible"
    echo "Try running: terraform output"
    exit 1
fi

if [[ -z "$PUBLIC_IP" ]] || [[ "$PUBLIC_IP" == "null" ]]; then
    error "EC2 instance has no public IP address"
    echo "The instance might not be running or doesn't have a public IP assigned"
    exit 1
fi

# Get SSH key from terraform output or environment variable
SSH_KEY_NAME=""
if terraform output -raw ssh_command &>/dev/null; then
    SSH_COMMAND=$(terraform output -raw ssh_command)
    log "Using SSH command from Terraform output"
    echo "Executing: $SSH_COMMAND"
    echo ""
    exec $SSH_COMMAND
else
    # Fallback to environment variables or defaults
    SSH_KEY_PATH="${SSH_KEY_PATH:-~/.ssh/id_rsa}"
    SSH_USER="${SSH_USER:-ec2-user}"
    
    # Expand tilde in path
    SSH_KEY_PATH="${SSH_KEY_PATH/#\~/$HOME}"
    
    # Check if SSH key exists
    if [[ ! -f "$SSH_KEY_PATH" ]]; then
        error "SSH key not found: $SSH_KEY_PATH"
        echo "Please:"
        echo "1. Create an EC2 key pair in AWS console"
        echo "2. Download the private key to ~/.ssh/"
        echo "3. Set correct permissions: chmod 600 ~/.ssh/your-key.pem"
        echo "4. Set SSH_KEY_PATH environment variable or use default ~/.ssh/id_rsa"
        exit 1
    fi
    
    # Check SSH key permissions
    key_perms=$(stat -c %a "$SSH_KEY_PATH" 2>/dev/null || stat -f %A "$SSH_KEY_PATH" 2>/dev/null)
    if [[ "$key_perms" != "600" ]]; then
        warning "SSH key permissions are too open: $key_perms"
        log "Fixing SSH key permissions..."
        chmod 600 "$SSH_KEY_PATH"
    fi
    
    log "SSH Details:"
    echo "  Host: $PUBLIC_IP"
    echo "  User: $SSH_USER"
    echo "  Key:  $SSH_KEY_PATH"
    echo ""
    
    # Connect via SSH
    log "Connecting to $ENV EC2 instance..."
    ssh -i "$SSH_KEY_PATH" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=10 \
        "$SSH_USER@$PUBLIC_IP"
fi
