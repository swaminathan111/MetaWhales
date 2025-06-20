#!/bin/bash

# CardSense AI Deployment Script for Vercel
# This script automates the Flutter web build and Vercel deployment process

set -e  # Exit on any error

echo "🚀 Starting CardSense AI deployment to Vercel..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    print_error "Vercel CLI is not installed. Please run: npm install -g vercel"
    exit 1
fi

# Step 1: Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
print_success "Build cache cleared"

# Step 2: Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get
print_success "Dependencies updated"

# Step 3: Run tests (optional)
if [ "$1" = "--skip-tests" ]; then
    print_warning "Skipping tests as requested"
else
    print_status "Running tests..."
    if flutter test; then
        print_success "All tests passed"
    else
        print_error "Tests failed. Use --skip-tests to deploy anyway"
        exit 1
    fi
fi

# Step 4: Build for web
print_status "Building Flutter web app..."
flutter build web --release --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true

if [ $? -eq 0 ]; then
    print_success "Flutter web build completed successfully"
else
    print_error "Flutter web build failed"
    exit 1
fi

# Step 5: Deploy to Vercel
print_status "Deploying to Vercel..."

if [ "$2" = "--prod" ]; then
    print_status "Deploying to production..."
    vercel --prod --yes
else
    print_status "Deploying to preview..."
    vercel --yes
fi

if [ $? -eq 0 ]; then
    print_success "Deployment completed successfully! 🎉"
    print_status "Your app should be available at the URL shown above"
else
    print_error "Deployment failed"
    exit 1
fi

echo ""
print_success "🎉 CardSense AI has been deployed successfully!"
echo ""
print_status "Next steps:"
echo "1. Update Google OAuth settings with your new domain"
echo "2. Update Supabase authentication settings"
echo "3. Test all features on the deployed app"
echo "4. Monitor the deployment in Vercel dashboard"
echo ""
print_status "For troubleshooting, check: docs/VERCEL_DEPLOYMENT_GUIDE.md" 