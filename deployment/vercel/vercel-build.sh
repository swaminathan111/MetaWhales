#!/bin/bash

# Vercel Build Script for Flutter Web
set -e

echo "🚀 Starting Flutter Web build for Vercel..."

# Install Flutter
echo "📦 Installing Flutter..."
cd /tmp
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:/tmp/flutter/bin"

# Verify Flutter installation
flutter --version
flutter doctor

# Go back to project directory
cd $VERCEL_PROJECT_ROOT

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "🔨 Building Flutter web app..."
flutter build web --release --web-renderer canvaskit

echo "✅ Build completed successfully!" 