#!/bin/bash

# 🏎️ Radar Rush Automated Release Script
# Automatically deploys the game to Test and Production tracks on iOS and Android.

# Exit immediately if a command exits with a non-zero status
set -e

# Color codes for pretty terminal printing
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${CYAN}[INFO] $1${NC}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

usage() {
    echo "Usage: $0 [ios|android] [test|prod]"
    echo "  Platforms: ios, android"
    echo "  Environments: test, prod"
    echo "  Example: $0 ios test"
    exit 1
}

# Validate arguments
if [ "$#" -ne 2 ]; then
    usage
fi

PLATFORM=$1
ENV=$2

# Ensure clean build environment
log_info "Cleaning Flutter build cache..."
flutter clean
log_info "Fetching Flutter dependencies..."
flutter pub get

# --- iOS DEPLOYMENT ---
if [ "$PLATFORM" = "ios" ]; then
    log_info "Starting iOS Deployment Flow..."
    cd ios
    
    if [ "$ENV" = "test" ]; then
        log_info "Building IPA and deploying to Apple TestFlight..."
        bundle exec fastlane beta
        log_success "iOS Test Release successfully uploaded to TestFlight!"
    elif [ "$ENV" = "prod" ]; then
        log_info "Generating Screenshots, Building release IPA, and deploying to Apple App Store..."
        bundle exec fastlane release
        log_success "iOS Production Release successfully submitted to the App Store!"
    else
        log_error "Invalid environment '$ENV' for iOS. Use 'test' or 'prod'."
        usage
    fi
    cd ..

# --- ANDROID DEPLOYMENT ---
elif [ "$PLATFORM" = "android" ]; then
    log_info "Starting Android Deployment Flow..."
    cd android
    
    if [ "$ENV" = "test" ]; then
        log_info "Building Android App Bundle (AAB) and deploying to Google Play Internal Test Track..."
        bundle exec fastlane beta
        log_success "Android Test Release successfully uploaded to Google Play Internal track!"
    elif [ "$ENV" = "prod" ]; then
        log_info "Building Android App Bundle (AAB) and deploying to Google Play Production..."
        bundle exec fastlane deploy
        log_success "Android Production Release successfully uploaded to Google Play Production!"
    else
        log_error "Invalid environment '$ENV' for Android. Use 'test' or 'prod'."
        usage
    fi
    cd ..

else
    log_error "Invalid platform '$PLATFORM'. Use 'ios' or 'android'."
    usage
fi
