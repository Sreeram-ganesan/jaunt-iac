#!/bin/bash

# Production Deployment Script
# Created: 2025-08-20
# Author: Sreeram-ganesan

echo "Starting production deployment..."

# Set environment variables
export ENV="production"
export LOG_LEVEL="info"

# Pull latest changes from main branch
git checkout main
git pull origin main

# Install dependencies
echo "Installing dependencies..."
npm install --production

# Build the application
echo "Building application..."
npm run build:prod

# Run tests
echo "Running smoke tests..."
npm run test:smoke

# Deploy to production server
echo "Deploying to production server..."
npm run deploy:prod

# Run post-deployment checks
echo "Running health checks..."
npm run healthcheck

echo "Production deployment completed successfully!"