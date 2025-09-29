#!/bin/bash

echo "🚀 SpelSmart - TestFlight Setup Script"
echo "======================================"

# Check if we're in the right directory
if [ ! -f "ios/project.yml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Check for required tools
echo "🔍 Checking required tools..."

if ! command -v xcodegen &> /dev/null; then
    echo "⚠️  XcodeGen not found. Installing..."
    brew install xcodegen
fi

if ! command -v fastlane &> /dev/null; then
    echo "⚠️  Fastlane not found. Installing..."
    brew install fastlane
fi

echo "✅ Tools check complete!"

# Generate Xcode project
echo "🏗️  Generating Xcode project..."
cd ios
xcodegen generate

if [ $? -eq 0 ]; then
    echo "✅ Xcode project generated successfully!"
else
    echo "❌ Failed to generate Xcode project"
    exit 1
fi

# Check for environment variables
echo "🔑 Checking App Store Connect API configuration..."

if [ -z "$ASC_KEY_ID" ] || [ -z "$ASC_ISSUER_ID" ] || [ -z "$ASC_API_KEY_P8" ]; then
    echo "⚠️  App Store Connect API keys not configured."
    echo ""
    echo "Please set these environment variables:"
    echo "export ASC_KEY_ID=\"your-key-id\""
    echo "export ASC_ISSUER_ID=\"your-issuer-id\""
    echo "export ASC_API_KEY_P8=\"your-api-key-content\""
    echo ""
    echo "You can get these from:"
    echo "👉 https://appstoreconnect.apple.com → Users and Access → Keys"
    echo ""
else
    echo "✅ App Store Connect API keys configured!"
fi

echo ""
echo "🎯 Next steps:"
echo "1. Open Learnfotball.xcodeproj in Xcode"
echo "2. Configure your Apple Developer Team"
echo "3. Run one of these commands:"
echo "   • fastlane ios beta    (Upload to TestFlight)"
echo "   • fastlane ios release (Prepare for App Store)"
echo ""
echo "📖 For detailed instructions, see APP_STORE_GUIDE.md"
echo ""
echo "🎉 Setup complete! Ready for TestFlight deployment!"