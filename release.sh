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
    echo "  No Arguments: Runs ALL releases (iOS & Android, Test & Prod)"
    echo "  Example: $0 ios test"
    exit 1
}

bump_version() {
    log_info "Bumping version in pubspec.yaml..."
    # Find the current version line (e.g., version: 1.0.0+1)
    VERSION_LINE=$(grep "^version: " pubspec.yaml)
    if [ -z "$VERSION_LINE" ]; then
        log_error "Could not find version line in pubspec.yaml"
        exit 1
    fi
    
    # Extract version name (e.g. 1.0.0) and build number (e.g. 1)
    VERSION_FULL=${VERSION_LINE#version: }
    VERSION_NAME=${VERSION_FULL%+*}
    BUILD_NUMBER=${VERSION_FULL#*+}
    
    # Split version name into major, minor, patch
    IFS='.' read -r -a VERSION_PARTS <<< "$VERSION_NAME"
    MAJOR=${VERSION_PARTS[0]}
    MINOR=${VERSION_PARTS[1]}
    PATCH=${VERSION_PARTS[2]}
    
    # Increment build number
    NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
    
    # Increment patch version
    NEW_PATCH=$((PATCH + 1))
    NEW_VERSION_NAME="${MAJOR}.${MINOR}.${NEW_PATCH}"
    NEW_VERSION_FULL="${NEW_VERSION_NAME}+${NEW_BUILD_NUMBER}"
    
    log_info "Old Version: $VERSION_FULL"
    log_info "New Version: $NEW_VERSION_FULL"
    
    # Update pubspec.yaml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i "" "s/^version: .*/version: $NEW_VERSION_FULL/" pubspec.yaml
    else
        sed -i "s/^version: .*/version: $NEW_VERSION_FULL/" pubspec.yaml
    fi
    log_success "Successfully bumped version to $NEW_VERSION_FULL in pubspec.yaml!"
}

# Run all platforms and environments if no arguments are provided
RUN_ALL=false
if [ "$#" -eq 0 ]; then
    log_info "No arguments provided. Initiating FULL Multi-Platform Release (iOS & Android, Test & Prod)..."
    RUN_ALL=true
elif [ "$#" -ne 2 ]; then
    usage
fi

# Automatically bump version on each release execution
bump_version

# Detect Flutter path
FLUTTER_BIN="flutter"
if ! command -v flutter &> /dev/null; then
    log_warning "Flutter not found in global PATH. Searching default custom paths..."
    if [ -f "/Users/sachin/.gemini/antigravity/flutter/bin/flutter" ]; then
        FLUTTER_BIN="/Users/sachin/.gemini/antigravity/flutter/bin/flutter"
        log_success "Found Flutter at $FLUTTER_BIN"
    elif [ -f "$HOME/.gemini/antigravity/flutter/bin/flutter" ]; then
        FLUTTER_BIN="$HOME/.gemini/antigravity/flutter/bin/flutter"
        log_success "Found Flutter at $FLUTTER_BIN"
    else
        log_error "Flutter command not found. Please ensure Flutter is installed and added to your PATH."
        exit 1
    fi
fi

show_ios_signing_diagnostic() {
    echo -e "\n${RED}================================================================================${NC}"
    log_error "iOS BUILD FAILED DUE TO SIGNING OR CAPABILITY MISMATCH!"
    echo -e "--------------------------------------------------------------------------------"
    echo -e "Reason: Your current wildcard provisioning profile (*) does not support"
    echo -e "        the 'Sign In with Apple' capability that Radar Rush requires."
    echo -e ""
    echo -e "${YELLOW}How to fix this in Xcode:${NC}"
    echo -e "  1. Open ${CYAN}ios/Runner.xcworkspace${NC} in Xcode."
    echo -e "  2. In the left panel, select the ${CYAN}Runner${NC} project root."
    echo -e "  3. Select the ${CYAN}Runner${NC} Target and open the ${CYAN}Signing & Capabilities${NC} tab."
    echo -e "  4. Ensure your developer Team is selected."
    echo -e "  5. Verify that ${CYAN}Sign In with Apple${NC} is listed under Capabilities."
    echo -e "     (If missing, click '+ Capability' and search/add 'Sign In with Apple')."
    echo -e "  6. If using automatic signing, Xcode will automatically register an explicit App ID."
    echo -e "  7. Once configured, re-run: ${GREEN}./release.sh${NC}"
    echo -e "${RED}================================================================================${NC}\n"
}

run_fastlane_ios() {
    local lane=$1
    if ! fastlane "$lane"; then
        show_ios_signing_diagnostic
        exit 65
    fi
}

if [ "$RUN_ALL" = "true" ]; then
    # Ensure clean build environment
    log_info "Cleaning Flutter build cache..."
    $FLUTTER_BIN clean
    log_info "Fetching Flutter dependencies..."
    $FLUTTER_BIN pub get

    # 1. iOS Test
    log_info "Starting iOS Test Deployment Flow (Development Build)..."
    cd ios
    log_info "Installing CocoaPods dependencies..."
    pod install
    run_fastlane_ios beta
    cd ..
    log_success "iOS Local Development Build successfully generated!"

    # 2. iOS Prod
    log_info "Starting iOS Production Deployment Flow..."
    cd ios
    log_info "Installing CocoaPods dependencies..."
    pod install
    run_fastlane_ios release
    cd ..
    log_success "iOS Production Release successfully submitted to the App Store!"

    # 3. Android Test
    log_info "Starting Android Test Deployment Flow..."
    cd android
    fastlane beta
    cd ..
    log_success "Android Test Release successfully uploaded to Google Play Internal track!"

    # 4. Android Prod
    log_info "Starting Android Production Deployment Flow..."
    cd android
    fastlane deploy
    cd ..
    log_success "Android Production Release successfully uploaded to Google Play Production!"

    log_success "🔥 FULL MULTI-PLATFORM RELEASE SUCCESSFULLY COMPLETED!"
    exit 0
fi

PLATFORM=$1
ENV=$2

# Ensure clean build environment
log_info "Cleaning Flutter build cache..."
$FLUTTER_BIN clean
log_info "Fetching Flutter dependencies..."
$FLUTTER_BIN pub get

# --- iOS DEPLOYMENT ---
if [ "$PLATFORM" = "ios" ]; then
    log_info "Starting iOS Deployment Flow..."
    cd ios
    log_info "Installing CocoaPods dependencies..."
    pod install
    
    if [ "$ENV" = "test" ]; then
        log_info "Building IPA using Local Development Certificates..."
        run_fastlane_ios beta
        log_success "iOS Local Development Build successfully generated!"
    elif [ "$ENV" = "prod" ]; then
        log_info "Generating Screenshots, Building release IPA, and deploying to Apple App Store..."
        run_fastlane_ios release
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
        fastlane beta
        log_success "Android Test Release successfully uploaded to Google Play Internal track!"
    elif [ "$ENV" = "prod" ]; then
        log_info "Building Android App Bundle (AAB) and deploying to Google Play Production..."
        fastlane deploy
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
