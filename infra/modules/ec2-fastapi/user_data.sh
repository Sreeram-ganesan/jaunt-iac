#!/bin/bash

# user_data.sh - EC2 Cloud-Init Script for FastAPI Deployment
# This script provisions Python environment, clones app repo, and starts FastAPI service

set -e  # Exit on any error

# Variables passed from Terraform
PROJECT_NAME="${project_name}"
ENVIRONMENT="${environment}"
APP_REPO_URL="${app_repo_url}"
APP_REPO_BRANCH="${app_repo_branch}"

# Database configuration
DB_HOST="${db_host}"
DB_PORT="${db_port}"
DB_NAME="${db_name}"
DB_USERNAME="${db_username}"
DB_PASSWORD="${db_password}"

# API configuration  
TAVILY_API_KEY="${tavily_api_key}"
GEMINI_API_KEY="${gemini_api_key}"

# S3 configuration
S3_BUCKET_NAME="${s3_bucket_name}"

# App configuration
APP_PORT="${app_port}"
LOG_LEVEL="${log_level}"
FASTAPI_ENV="${fastapi_env}"

# Directories
APP_DIR="/opt/$PROJECT_NAME"
LOG_DIR="/var/log/$PROJECT_NAME"
SERVICE_USER="fastapi"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/user-data.log
}

log "Starting FastAPI deployment for $PROJECT_NAME-$ENVIRONMENT"

# Update system
log "Updating system packages"
yum update -y

# Install required packages
log "Installing required packages"
yum install -y \
    python3 \
    python3-pip \
    git \
    wget \
    curl \
    htop \
    vim \
    systemd \
    gcc \
    python3-devel

# Create service user
log "Creating service user: $SERVICE_USER"
useradd -r -s /bin/bash -d $APP_DIR $SERVICE_USER || true

# Create directories
log "Creating application directories"
mkdir -p $APP_DIR
mkdir -p $LOG_DIR
chown -R $SERVICE_USER:$SERVICE_USER $APP_DIR
chown -R $SERVICE_USER:$SERVICE_USER $LOG_DIR

# Upgrade pip
log "Upgrading pip"
python3 -m pip install --upgrade pip

# Install common Python packages
log "Installing common Python packages"
pip3 install \
    fastapi \
    uvicorn \
    psycopg2-binary \
    boto3 \
    requests \
    python-dotenv \
    pydantic \
    sqlalchemy

# Clone application repository
log "Cloning application repository"
cd /opt
if [ -d "$PROJECT_NAME" ]; then
    rm -rf "$PROJECT_NAME"
fi

# Use a simple FastAPI app if repository doesn't exist
if ! git clone -b $APP_REPO_BRANCH $APP_REPO_URL $PROJECT_NAME; then
    log "Repository clone failed, creating simple FastAPI app"
    mkdir -p $APP_DIR
    cat > $APP_DIR/main.py << 'EOF'
from fastapi import FastAPI, HTTPException
from datetime import datetime
import os
import psycopg2
import boto3
import json

app = FastAPI(title="FastAPI Infrastructure Demo", version="1.0.0")

@app.get("/")
async def root():
    return {
        "message": "FastAPI Infrastructure Demo",
        "timestamp": datetime.now().isoformat(),
        "environment": os.getenv("FASTAPI_ENV", "unknown")
    }

@app.get("/health")
async def health():
    checks = {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "environment": os.getenv("FASTAPI_ENV", "unknown"),
        "checks": {}
    }
    
    # Database connectivity check
    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST"),
            port=os.getenv("DB_PORT", 5432),
            database=os.getenv("DB_NAME"),
            user=os.getenv("DB_USERNAME"),
            password=os.getenv("DB_PASSWORD")
        )
        conn.close()
        checks["checks"]["database"] = "connected"
    except Exception as e:
        checks["checks"]["database"] = f"error: {str(e)}"
        checks["status"] = "degraded"
    
    # S3 connectivity check
    try:
        s3 = boto3.client('s3')
        bucket_name = os.getenv("S3_BUCKET_NAME")
        if bucket_name:
            s3.head_bucket(Bucket=bucket_name)
            checks["checks"]["s3"] = "accessible"
        else:
            checks["checks"]["s3"] = "no bucket configured"
    except Exception as e:
        checks["checks"]["s3"] = f"error: {str(e)}"
        checks["status"] = "degraded"
    
    return checks

@app.get("/api/test")
async def api_test():
    """Test external API connectivity"""
    import requests
    
    tests = {}
    
    # Test Tavily API (if key provided)
    if os.getenv("TAVILY_API_KEY"):
        try:
            # This is a placeholder - adjust based on actual Tavily API
            tests["tavily"] = "api key configured"
        except Exception as e:
            tests["tavily"] = f"error: {str(e)}"
    else:
        tests["tavily"] = "no api key configured"
    
    # Test Gemini API (if key provided)  
    if os.getenv("GEMINI_API_KEY"):
        try:
            # This is a placeholder - adjust based on actual Gemini API
            tests["gemini"] = "api key configured"
        except Exception as e:
            tests["gemini"] = f"error: {str(e)}"
    else:
        tests["gemini"] = "no api key configured"
    
    return {
        "external_apis": tests,
        "timestamp": datetime.now().isoformat()
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=int(os.getenv("APP_PORT", 8000)),
        log_level=os.getenv("LOG_LEVEL", "info")
    )
EOF

    # Create requirements.txt
    cat > $APP_DIR/requirements.txt << 'EOF'
fastapi>=0.104.1
uvicorn[standard]>=0.24.0
psycopg2-binary>=2.9.7
boto3>=1.29.0
requests>=2.31.0
python-dotenv>=1.0.0
pydantic>=2.5.0
sqlalchemy>=2.0.23
EOF
fi

# Change ownership
chown -R $SERVICE_USER:$SERVICE_USER $APP_DIR

# Install application dependencies
log "Installing application dependencies"
cd $APP_DIR
if [ -f "requirements.txt" ]; then
    sudo -u $SERVICE_USER pip3 install -r requirements.txt
fi

# Create environment file
log "Creating environment file"
cat > $APP_DIR/.env << EOF
# Database Configuration
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD

# API Configuration
TAVILY_API_KEY=$TAVILY_API_KEY
GEMINI_API_KEY=$GEMINI_API_KEY

# S3 Configuration
S3_BUCKET_NAME=$S3_BUCKET_NAME

# App Configuration
APP_PORT=$APP_PORT
LOG_LEVEL=$LOG_LEVEL
FASTAPI_ENV=$FASTAPI_ENV

# Additional settings
PROJECT_NAME=$PROJECT_NAME
ENVIRONMENT=$ENVIRONMENT
EOF

chown $SERVICE_USER:$SERVICE_USER $APP_DIR/.env
chmod 600 $APP_DIR/.env

# Create systemd service file
log "Creating systemd service"
cat > /etc/systemd/system/$PROJECT_NAME.service << EOF
[Unit]
Description=FastAPI application for $PROJECT_NAME
After=network.target

[Service]
Type=exec
User=$SERVICE_USER
Group=$SERVICE_USER
WorkingDirectory=$APP_DIR
Environment=PATH=/usr/local/bin:/usr/bin:/bin
EnvironmentFile=$APP_DIR/.env
ExecStart=/usr/bin/python3 -m uvicorn main:app --host 0.0.0.0 --port $APP_PORT --log-level $LOG_LEVEL
Restart=always
RestartSec=5

# Security settings
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=$APP_DIR $LOG_DIR

# Logging
StandardOutput=append:$LOG_DIR/app.log
StandardError=append:$LOG_DIR/error.log

[Install]
WantedBy=multi-user.target
EOF

# Create log rotation configuration
log "Setting up log rotation"
cat > /etc/logrotate.d/$PROJECT_NAME << EOF
$LOG_DIR/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0644 $SERVICE_USER $SERVICE_USER
    postrotate
        systemctl reload $PROJECT_NAME || true
    endscript
}
EOF

# Reload systemd and start service
log "Starting FastAPI service"
systemctl daemon-reload
systemctl enable $PROJECT_NAME
systemctl start $PROJECT_NAME

# Wait for service to start
sleep 10

# Check service status
log "Checking service status"
if systemctl is-active --quiet $PROJECT_NAME; then
    log "FastAPI service started successfully"
    
    # Test health endpoint
    sleep 5
    if curl -f -s http://localhost:$APP_PORT/health > /dev/null; then
        log "Health check passed"
    else
        log "Health check failed"
    fi
else
    log "FastAPI service failed to start"
    systemctl status $PROJECT_NAME || true
    journalctl -u $PROJECT_NAME -n 50 || true
fi

log "FastAPI deployment completed for $PROJECT_NAME-$ENVIRONMENT"

# Create a simple status script
cat > /usr/local/bin/fastapi-status << 'EOF'
#!/bin/bash
echo "FastAPI Service Status:"
systemctl status fastapi-infra
echo ""
echo "Recent logs:"
journalctl -u fastapi-infra -n 20 --no-pager
EOF
chmod +x /usr/local/bin/fastapi-status

log "User data script completed successfully"