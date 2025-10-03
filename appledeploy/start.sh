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

# Create virtual environment for dependencies
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies in virtual environment
if ! python -c "import flask" &> /dev/null; then
    echo "📦 Installing Flask dependencies in venv..."
    pip install -r requirements.txt
fi

echo "✅ Dependencies ready"
echo "🚀 Starting AppleDeploy server..."
echo ""
echo "💡 Open browser to: http://localhost:5000"
echo "🎯 Ready to deploy iOS apps to TestFlight!"
echo ""

# Start server with virtual environment
python server.py