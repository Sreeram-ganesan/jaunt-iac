#!/bin/bash

# Development Deployment Script
# Created: 2025-08-20
# Author: Sreeram-ganesan

echo "Starting development deployment..."

# Set environment variables
export ENV="development"
export LOG_LEVEL="debug"

# Pull latest changes from development branch
git checkout develop
git pull origin develop

# Install dependencies
echo "Installing dependencies..."
npm install

# Build the application
echo "Building application..."
npm run build:dev

# Run tests
echo "Running tests..."
npm test

# Deploy to development server
echo "Deploying to development server..."
npm run deploy:dev

echo "Development deployment completed successfully!"