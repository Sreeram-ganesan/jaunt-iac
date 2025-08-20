#!/bin/bash
set -e

# Usage: ./ssh.sh <env>
# Example: ./ssh.sh prod

ENV="$1"
if [[ -z "$ENV" ]]; then
  echo "Usage: $0 <dev|prod>"
  exit 1
fi

ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../envs/$ENV" && pwd)"

if [[ ! -d "$ENV_DIR" ]]; then
  echo "❌ Environment directory not found: $ENV_DIR"
  exit 1
fi

cd "$ENV_DIR"

# Get public IP from Terraform output
PUBLIC_IP=$(terraform output -raw ec2_public_ip 2>/dev/null || true)
if [[ -z "$PUBLIC_IP" ]]; then
  echo "❌ Could not get EC2 public IP from Terraform output."
  echo "Make sure the environment is deployed and 'ec2_public_ip' is an output."
  exit 1
fi

# Set SSH key (override with SSH_KEY_PATH env var if needed)
SSH_KEY_PATH="${SSH_KEY_PATH:-~/.ssh/id_rsa}"

echo "🔗 Connecting to $ENV EC2 instance at $PUBLIC_IP ..."
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no ec2-user@"$PUBLIC_IP"
