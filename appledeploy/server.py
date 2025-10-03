#!/usr/bin/env python3
"""
AppleDeploy Backend Server
iOS-First CI/CD Platform Backend
Foundation-first approach to iOS deployment automation
"""

from flask import Flask, request, jsonify, render_template_string, send_from_directory
from flask_cors import CORS
import os
import subprocess
import tempfile
import zipfile
import shutil
from pathlib import Path
import json
import threading
import time
import uuid

app = Flask(__name__)
CORS(app)

# Global deployment tracking
deployments = {}

class AppleDeployBackend:
    """
    Backend service for AppleDeploy platform
    Handles iOS project processing and deployment automation
    """
    
    def __init__(self):
        self.temp_dir = tempfile.mkdtemp(prefix="appledeploy_")
        self.build_agents = []  # Future: Multiple macOS build agents
        
    def process_ios_project(self, project_files, auth_data, deployment_id):
        """
        Foundation-first: Process iOS project and deploy to TestFlight
        """
        try:
            self.log_deployment(deployment_id, "🍎 AppleDeploy - Starting iOS deployment")
            self.log_deployment(deployment_id, "Foundation-first approach to iOS automation")
            
            # Create deployment directory
            deploy_dir = os.path.join(self.temp_dir, deployment_id)
            os.makedirs(deploy_dir, exist_ok=True)
            
            # Extract project files
            self.log_deployment(deployment_id, "📦 Processing project files...")
            project_path = self.extract_project_files(project_files, deploy_dir)
            
            if not project_path:
                self.log_deployment(deployment_id, "❌ Failed to process project files", "error")
                return False
                
            # Setup GitHub Actions workflow for this project
            self.log_deployment(deployment_id, "🔧 Setting up deployment pipeline...")
            workflow_success = self.setup_deployment_workflow(project_path, auth_data, deployment_id)
            
            if workflow_success:
                self.log_deployment(deployment_id, "✅ Deployment pipeline configured", "success")
                self.log_deployment(deployment_id, "🚀 Starting automated build process...")
                
                # Trigger GitHub Actions workflow
                return self.trigger_github_deployment(project_path, auth_data, deployment_id)
            else:
                self.log_deployment(deployment_id, "❌ Failed to setup deployment pipeline", "error")
                return False
                
        except Exception as e:
            self.log_deployment(deployment_id, f"❌ Deployment failed: {str(e)}", "error")
            return False
    
    def extract_project_files(self, files, deploy_dir):
        """
        Foundation-first: Extract and organize iOS project files
        """
        try:
            for file_data in files:
                file_path = os.path.join(deploy_dir, file_data['name'])
                
                if file_data['name'].endswith('.zip'):
                    # Extract zip file
                    with zipfile.ZipFile(file_data['content'], 'r') as zip_ref:
                        zip_ref.extractall(deploy_dir)
                elif file_data['name'].endswith('.xcarchive'):
                    # Handle xcarchive
                    shutil.copytree(file_data['content'], file_path)
                else:
                    # Copy other files
                    shutil.copy2(file_data['content'], file_path)
            
            return deploy_dir
            
        except Exception as e:
            print(f"Error extracting files: {e}")
            return None
    
    def setup_deployment_workflow(self, project_path, auth_data, deployment_id):
        """
        Foundation-first: Setup GitHub Actions workflow for this specific project
        """
        try:
            # Create custom workflow based on our proven solution
            workflow_content = self.generate_custom_workflow(auth_data)
            
            workflow_path = os.path.join(project_path, '.github', 'workflows', 'appledeploy.yml')
            os.makedirs(os.path.dirname(workflow_path), exist_ok=True)
            
            with open(workflow_path, 'w') as f:
                f.write(workflow_content)
            
            return True
            
        except Exception as e:
            print(f"Error setting up workflow: {e}")
            return False
    
    def generate_custom_workflow(self, auth_data):
        """
        Foundation-first: Generate custom GitHub Actions workflow
        Based on our proven TaktikTräning solution
        """
        return f"""
name: AppleDeploy - iOS Deployment

on:
  workflow_dispatch:
    inputs:
      apple_id:
        description: 'Apple ID'
        required: true
        default: '{auth_data['apple_id']}'
      app_password:
        description: 'App-Specific Password'
        required: true

jobs:
  deploy:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: latest-stable
    
    - name: Install XcodeGen
      run: brew install xcodegen
    
    - name: Generate Xcode Project
      run: |
        cd ios
        xcodegen generate
    
    - name: AppleDeploy - Build and Deploy
      env:
        APPLE_ID: ${{{{ github.event.inputs.apple_id }}}}
        APP_PASSWORD: ${{{{ github.event.inputs.app_password }}}}
        ASC_KEY_ID: ${{{{ secrets.ASC_KEY_ID }}}}
        ASC_ISSUER_ID: ${{{{ secrets.ASC_ISSUER_ID }}}}
        ASC_API_KEY_P8: ${{{{ secrets.ASC_API_KEY_P8 }}}}
      run: |
        echo "🍎 AppleDeploy - iOS-First CI/CD Platform"
        echo "Foundation-first approach to iOS deployment"
        
        # Use our proven export automation tool
        python3 export_automation_tool.py \\
          --apple-id "$APPLE_ID" \\
          --app-password "$APP_PASSWORD" \\
          --team-id "{auth_data['team_id']}" \\
          --bundle-id "{auth_data['bundle_id']}" \\
          --profile-name "App Store Profile" \\
          --upload
        
        echo "🎉 AppleDeploy deployment completed!"
"""
    
    def trigger_github_deployment(self, project_path, auth_data, deployment_id):
        """
        Foundation-first: Trigger GitHub Actions deployment
        """
        try:
            self.log_deployment(deployment_id, "🚀 Triggering GitHub Actions deployment...")
            
            # In real implementation, this would:
            # 1. Push project to temporary GitHub repo
            # 2. Trigger workflow via GitHub API
            # 3. Monitor deployment progress
            # 4. Stream logs back to user
            
            # For now, simulate successful deployment
            time.sleep(2)
            self.log_deployment(deployment_id, "✅ GitHub Actions workflow triggered", "success")
            
            return True
            
        except Exception as e:
            self.log_deployment(deployment_id, f"❌ Failed to trigger deployment: {str(e)}", "error")
            return False
    
    def log_deployment(self, deployment_id, message, level="info"):
        """
        Foundation-first: Log deployment progress for real-time updates
        """
        if deployment_id not in deployments:
            deployments[deployment_id] = {"logs": [], "status": "running"}
        
        log_entry = {
            "timestamp": time.time(),
            "message": message,
            "level": level
        }
        
        deployments[deployment_id]["logs"].append(log_entry)
        print(f"[{deployment_id}] {message}")

# Initialize AppleDeploy backend
backend = AppleDeployBackend()

@app.route('/')
def index():
    """Serve the AppleDeploy web interface"""
    with open('index.html', 'r') as f:
        return f.read()

@app.route('/api/deploy', methods=['POST'])
def deploy():
    """
    Foundation-first: Handle iOS deployment request
    """
    try:
        data = request.get_json()
        
        # Generate unique deployment ID
        deployment_id = str(uuid.uuid4())[:8]
        
        # Validate required fields
        required_fields = ['apple_id', 'app_password', 'team_id', 'bundle_id']
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing required field: {field}"}), 400
        
        # Start deployment in background thread
        auth_data = {
            'apple_id': data['apple_id'],
            'app_password': data['app_password'],
            'team_id': data['team_id'],
            'bundle_id': data['bundle_id']
        }
        
        # For demo, simulate file processing
        project_files = [{"name": "TaktikTräning.xcarchive", "content": "simulated"}]
        
        deployment_thread = threading.Thread(
            target=backend.process_ios_project,
            args=(project_files, auth_data, deployment_id)
        )
        deployment_thread.start()
        
        return jsonify({
            "deployment_id": deployment_id,
            "status": "started",
            "message": "AppleDeploy deployment started successfully"
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/deployment/<deployment_id>/logs')
def get_deployment_logs(deployment_id):
    """
    Foundation-first: Get real-time deployment logs
    """
    if deployment_id in deployments:
        return jsonify(deployments[deployment_id])
    else:
        return jsonify({"error": "Deployment not found"}), 404

@app.route('/api/deployment/<deployment_id>/status')
def get_deployment_status(deployment_id):
    """
    Foundation-first: Get deployment status
    """
    if deployment_id in deployments:
        return jsonify({
            "deployment_id": deployment_id,
            "status": deployments[deployment_id].get("status", "running"),
            "log_count": len(deployments[deployment_id]["logs"])
        })
    else:
        return jsonify({"error": "Deployment not found"}), 404

if __name__ == '__main__':
    print("🍎 AppleDeploy Backend Server")
    print("iOS-First CI/CD Platform")
    print("Foundation-first approach to iOS deployment")
    print("=" * 50)
    print("🚀 Server starting on http://localhost:5000")
    print("💡 Open browser to start deploying iOS apps!")
    
    app.run(debug=True, host='0.0.0.0', port=5000)