#!/bin/bash

echo "🍎 AppleDeploy - iOS-First CI/CD Platform"
echo "Foundation-first approach to iOS deployment"
echo "=" * 50

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Installing..."
    sudo apt update
    sudo apt install -y python3 python3-pip
fi

# Check if Flask is installed
if ! python3 -c "import flask" &> /dev/null; then
    echo "📦 Installing Flask dependencies..."
    pip3 install -r requirements.txt
fi

echo "✅ Dependencies ready"
echo "🚀 Starting AppleDeploy server..."
echo ""
echo "💡 Open browser to: http://localhost:5000"
echo "🎯 Ready to deploy iOS apps to TestFlight!"
echo ""

# Start server
python3 server.py