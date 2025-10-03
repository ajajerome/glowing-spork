#!/usr/bin/env python3
"""
AppleDeploy Mac Integration Backend
ACTUALLY connects to MacinCloud server and deploys iOS apps
Foundation-first approach: Real Mac server integration, not simulation
"""

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
import subprocess
import paramiko
import tempfile
import json
import time
import threading
import uuid
from datetime import datetime
from pathlib import Path
import zipfile
import shutil

app = Flask(__name__)
CORS(app)

# Mac server configuration
MAC_SERVER = {
    "host": "195.82.45.146",
    "username": "user944271",
    "password": "nps16068tnv",
    "port": 22
}

# Global deployment tracking
live_deployments = {}

class MacServerDeployment:
    """
    Real Mac server deployment - connects to actual MacinCloud server
    Foundation-first: No simulation, real deployment to TestFlight
    """
    
    def __init__(self):
        self.ssh_client = None
        self.sftp_client = None
        
    def connect_to_mac_server(self):
        """
        Foundation-first: Establish SSH connection to Mac server
        """
        try:
            self.ssh_client = paramiko.SSHClient()
            self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            
            self.ssh_client.connect(
                hostname=MAC_SERVER["host"],
                username=MAC_SERVER["username"],
                password=MAC_SERVER["password"],
                port=MAC_SERVER["port"],
                timeout=30
            )
            
            self.sftp_client = self.ssh_client.open_sftp()
            return True
            
        except Exception as e:
            print(f"❌ Mac server connection failed: {e}")
            return False
    
    def upload_project_to_mac(self, local_zip_path, deployment_id):
        """
        Foundation-first: Upload iOS project to Mac server
        """
        try:
            if not self.sftp_client:
                return False
            
            # Create remote directory
            remote_dir = f"/tmp/appledeploy_{deployment_id}"
            self.execute_command(f"mkdir -p {remote_dir}")
            
            # Upload zip file
            remote_zip_path = f"{remote_dir}/project.zip"
            self.sftp_client.put(local_zip_path, remote_zip_path)
            
            # Extract on Mac server
            self.execute_command(f"cd {remote_dir} && unzip -q project.zip")
            
            return remote_dir
            
        except Exception as e:
            print(f"❌ Project upload failed: {e}")
            return None
    
    def execute_command(self, command):
        """
        Foundation-first: Execute command on Mac server
        """
        try:
            stdin, stdout, stderr = self.ssh_client.exec_command(command)
            exit_status = stdout.channel.recv_exit_status()
            
            output = stdout.read().decode('utf-8')
            error = stderr.read().decode('utf-8')
            
            return {
                "exit_status": exit_status,
                "output": output,
                "error": error
            }
            
        except Exception as e:
            return {
                "exit_status": -1,
                "output": "",
                "error": str(e)
            }
    
    def deploy_ios_app_on_mac(self, project_dir, auth_data, deployment_id):
        """
        Foundation-first: Execute complete iOS deployment on Mac server
        """
        try:
            # Step 1: Setup deployment script on Mac
            deployment_script = f"""#!/bin/bash
echo "🍎 AppleDeploy Mac Server Deployment"
echo "Foundation-first approach: Real TestFlight deployment"
echo "=" * 60

cd {project_dir}

# Find iOS project
if [ -d "ios" ]; then
    cd ios
elif [ -f "project.yml" ]; then
    echo "✅ Found XcodeGen project"
elif [ -f "*.xcodeproj" ]; then
    echo "✅ Found Xcode project"
else
    echo "❌ No iOS project found"
    exit 1
fi

# Generate Xcode project if needed
if [ -f "project.yml" ]; then
    echo "🔧 Generating Xcode project..."
    xcodegen generate
    if [ $? -ne 0 ]; then
        echo "❌ XcodeGen failed"
        exit 1
    fi
fi

# Find .xcodeproj
XCODE_PROJECT=$(find . -name "*.xcodeproj" | head -1)
if [ -z "$XCODE_PROJECT" ]; then
    echo "❌ No .xcodeproj found"
    exit 1
fi

PROJECT_NAME=$(basename "$XCODE_PROJECT" .xcodeproj)
echo "✅ Found project: $PROJECT_NAME"

# Build and archive
echo "🏗️ Building and archiving..."
xcodebuild \\
  -project "$XCODE_PROJECT" \\
  -scheme "$PROJECT_NAME" \\
  -configuration Release \\
  -archivePath "./build/$PROJECT_NAME.xcarchive" \\
  -allowProvisioningUpdates \\
  -allowProvisioningDeviceRegistration \\
  CODE_SIGN_STYLE="Automatic" \\
  DEVELOPMENT_TEAM="{auth_data['teamId']}" \\
  PRODUCT_BUNDLE_IDENTIFIER="{auth_data.get('bundleId', 'com.ajagames.taktiktraning')}" \\
  archive

if [ $? -ne 0 ]; then
    echo "❌ Archive failed"
    exit 1
fi

echo "✅ Archive created successfully"

# Create export.plist
cat > export.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>{auth_data['teamId']}</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
PLIST

# Export to IPA
echo "📦 Exporting to IPA..."
mkdir -p export
xcodebuild \\
  -exportArchive \\
  -archivePath "./build/$PROJECT_NAME.xcarchive" \\
  -exportPath ./export \\
  -exportOptionsPlist ./export.plist

if [ $? -ne 0 ]; then
    echo "❌ Export failed"
    exit 1
fi

echo "✅ Export completed"

# Find IPA file
IPA_FILE=$(find ./export -name "*.ipa" | head -1)
if [ -z "$IPA_FILE" ]; then
    echo "❌ No IPA file found"
    exit 1
fi

echo "📱 IPA found: $IPA_FILE"

# Upload to TestFlight
echo "🚀 Uploading to TestFlight..."
xcrun altool \\
  --upload-app \\
  --type ios \\
  --file "$IPA_FILE" \\
  --username "{auth_data['appleId']}" \\
  --password "{auth_data['appPassword']}"

if [ $? -eq 0 ]; then
    echo "🎉 SUCCESS! App uploaded to TestFlight!"
    echo "📱 Check TestFlight app on iPhone in 5-10 minutes!"
else
    echo "❌ TestFlight upload failed"
    exit 1
fi
"""
            
            # Upload and execute deployment script
            script_path = f"{project_dir}/deploy.sh"
            
            # Write script to Mac server
            with self.sftp_client.open(script_path, 'w') as f:
                f.write(deployment_script)
            
            # Make executable
            self.execute_command(f"chmod +x {script_path}")
            
            # Execute deployment
            result = self.execute_command(f"cd {project_dir} && ./deploy.sh")
            
            return result["exit_status"] == 0
            
        except Exception as e:
            print(f"❌ Mac deployment failed: {e}")
            return False
    
    def disconnect(self):
        """
        Foundation-first: Clean disconnect from Mac server
        """
        if self.sftp_client:
            self.sftp_client.close()
        if self.ssh_client:
            self.ssh_client.close()

class AppleDeployLiveBackend:
    """
    AppleDeploy Live Backend - Real Mac server integration
    Foundation-first: Actually deploys to TestFlight, no simulation
    """
    
    def __init__(self):
        self.temp_dir = tempfile.mkdtemp(prefix="appledeploy_live_")
        
    def handle_live_deployment(self, project_file, auth_data, deployment_id):
        """
        Foundation-first: Handle real deployment to Mac server
        """
        mac_deployment = MacServerDeployment()
        
        try:
            self.log_deployment(deployment_id, "🍎 AppleDeploy Live Deployment")
            self.log_deployment(deployment_id, "Foundation-first: Real Mac server integration")
            
            # Connect to Mac server
            self.log_deployment(deployment_id, "🖥️ Connecting to Mac server...")
            if not mac_deployment.connect_to_mac_server():
                self.log_deployment(deployment_id, "❌ Failed to connect to Mac server", "error")
                return False
            
            self.log_deployment(deployment_id, "✅ Connected to MacinCloud server")
            
            # Save uploaded file properly
            temp_zip_path = os.path.join(self.temp_dir, f"{deployment_id}.zip")
            
            # Read file content before it closes
            file_content = project_file.read()
            project_file.seek(0)  # Reset file pointer
            
            # Write to temp file
            with open(temp_zip_path, 'wb') as f:
                f.write(file_content)
            
            self.log_deployment(deployment_id, f"📦 File saved: {os.path.basename(temp_zip_path)} ({len(file_content)} bytes)")
            
            # Upload to Mac server
            self.log_deployment(deployment_id, "📤 Uploading project to Mac server...")
            remote_dir = mac_deployment.upload_project_to_mac(temp_zip_path, deployment_id)
            
            if not remote_dir:
                self.log_deployment(deployment_id, "❌ Failed to upload project", "error")
                return False
            
            self.log_deployment(deployment_id, "✅ Project uploaded successfully")
            
            # Execute deployment on Mac
            self.log_deployment(deployment_id, "🚀 Starting deployment on Mac server...")
            success = mac_deployment.deploy_ios_app_on_mac(remote_dir, auth_data, deployment_id)
            
            if success:
                self.log_deployment(deployment_id, "🎉 Live deployment completed!", "success")
                self.log_deployment(deployment_id, "📱 Check TestFlight app on your iPhone!", "success")
            else:
                self.log_deployment(deployment_id, "❌ Deployment failed", "error")
            
            return success
            
        except Exception as e:
            self.log_deployment(deployment_id, f"❌ Live deployment error: {str(e)}", "error")
            return False
        finally:
            mac_deployment.disconnect()
    
    def log_deployment(self, deployment_id, message, level="info"):
        """
        Foundation-first: Real-time deployment logging
        """
        if deployment_id not in live_deployments:
            live_deployments[deployment_id] = {
                "logs": [],
                "status": "running",
                "created_at": datetime.now().isoformat()
            }
        
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "message": message,
            "level": level
        }
        
        live_deployments[deployment_id]["logs"].append(log_entry)
        print(f"[LIVE-{deployment_id}] {message}")

# Initialize live backend
live_backend = AppleDeployLiveBackend()

@app.route('/')
def index():
    """Serve super simple AppleDeploy interface"""
    try:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        html_path = os.path.join(current_dir, 'simple_working.html')
        with open(html_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        return """
        <h1>🍎 AppleDeploy Live</h1>
        <p>Zip → TestFlight in 5 minutes</p>
        <p>Real Mac server integration active!</p>
        """

@app.route('/api/deploy/live', methods=['POST'])
def live_deploy():
    """
    Foundation-first: Real deployment to Mac server
    """
    print("🚀 POST request received at /api/deploy/live")
    try:
        # Get uploaded file
        if 'project_file' not in request.files:
            return jsonify({"error": "No project file uploaded"}), 400
        
        project_file = request.files['project_file']
        
        # Get auth data
        apple_id = request.form.get('apple_id')
        app_password = request.form.get('app_password')
        team_id = request.form.get('team_id', 'MW98Z2Q68W')
        bundle_id = request.form.get('bundle_id', 'com.ajagames.taktiktraning')
        
        if not apple_id or not app_password:
            return jsonify({"error": "Apple ID and app-specific password required"}), 400
        
        # Generate deployment ID
        deployment_id = str(uuid.uuid4())[:8]
        
        # Prepare auth data
        auth_data = {
            'appleId': apple_id,
            'appPassword': app_password,
            'teamId': team_id,
            'bundleId': bundle_id
        }
        
        # Start live deployment in background
        deployment_thread = threading.Thread(
            target=live_backend.handle_live_deployment,
            args=(project_file, auth_data, deployment_id)
        )
        deployment_thread.start()
        
        return jsonify({
            "deployment_id": deployment_id,
            "status": "started",
            "message": "Live deployment to Mac server started"
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/deployment/<deployment_id>/live-status')
def get_live_status(deployment_id):
    """Get real-time deployment status from Mac server"""
    if deployment_id in live_deployments:
        return jsonify(live_deployments[deployment_id])
    else:
        return jsonify({"error": "Deployment not found"}), 404

if __name__ == '__main__':
    print("🍎 AppleDeploy Live Backend")
    print("Real Mac server integration - MacinCloud")
    print("=" * 50)
    print(f"🖥️ Mac Server: {MAC_SERVER['host']}")
    print(f"👤 Username: {MAC_SERVER['username']}")
    print("🚀 Server starting on http://localhost:5003")
    print("💡 Upload iOS projects → Real TestFlight deployment!")
    
    # Test Mac server connection on startup
    test_deployment = MacServerDeployment()
    if test_deployment.connect_to_mac_server():
        print("✅ Mac server connection verified")
        test_deployment.disconnect()
    else:
        print("❌ Mac server connection failed - check credentials")
    
    app.run(debug=True, host='0.0.0.0', port=5003)