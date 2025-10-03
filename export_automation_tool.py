#!/usr/bin/env python3
"""
iOS Export Automation Tool
Automates the xcodebuild export step that requires Apple ID authentication
Foundation-first approach to solving iOS deployment from Linux
"""

import os
import sys
import subprocess
import json
import time
import argparse
from pathlib import Path

class iOSExportAutomator:
    """
    Automates iOS app export for TestFlight deployment
    Handles Apple ID authentication and provisioning profile management
    """
    
    def __init__(self, apple_id, app_password, team_id, bundle_id):
        self.apple_id = apple_id
        self.app_password = app_password
        self.team_id = team_id
        self.bundle_id = bundle_id
        self.archive_path = None
        self.export_path = "./build"
        
    def setup_keychain_authentication(self):
        """
        Foundation-first: Setup Apple ID in keychain for export authentication
        """
        print("🔐 Setting up Apple ID authentication...")
        
        try:
            # Add Apple ID to keychain
            cmd = [
                "security", "add-generic-password",
                "-a", self.apple_id,
                "-w", self.app_password,
                "-s", "deliver.apple.com"
            ]
            subprocess.run(cmd, check=True, capture_output=True)
            print("✅ Apple ID added to keychain")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to add Apple ID to keychain: {e}")
            return False
    
    def create_export_plist(self, profile_name):
        """
        Foundation-first: Create export options plist with automatic signing
        GitHub Actions can't install profiles, so use automatic approach
        """
        print(f"📋 Creating export.plist with automatic signing...")
        
        export_config = {
            "method": "app-store-connect",  # Use app-store-connect (not deprecated)
            "teamID": self.team_id,
            "signingStyle": "automatic",    # Let xcodebuild find profiles automatically
            "uploadBitcode": False,
            "uploadSymbols": True
        }
        
        plist_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>{export_config['method']}</string>
    <key>teamID</key>
    <string>{export_config['teamID']}</string>
    <key>signingStyle</key>
    <string>{export_config['signingStyle']}</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>"""
        
        with open("export.plist", "w") as f:
            f.write(plist_content)
            
        print("✅ export.plist created")
        return True
    
    def export_archive(self, archive_path, profile_name):
        """
        Foundation-first: Export archive to IPA with proper authentication
        """
        self.archive_path = archive_path
        
        if not os.path.exists(archive_path):
            print(f"❌ Archive not found: {archive_path}")
            return False
            
        print(f"🔧 Exporting {archive_path} to IPA...")
        
        # Create export directory
        os.makedirs(self.export_path, exist_ok=True)
        
        # Create export plist
        if not self.create_export_plist(profile_name):
            return False
            
        # Setup authentication
        if not self.setup_keychain_authentication():
            return False
            
        try:
            # Run xcodebuild export
            cmd = [
                "xcodebuild",
                "-exportArchive",
                "-archivePath", archive_path,
                "-exportPath", self.export_path,
                "-exportOptionsPlist", "./export.plist"
            ]
            
            print(f"🚀 Running: {' '.join(cmd)}")
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                print("✅ Export succeeded!")
                
                # Find generated IPA
                ipa_files = list(Path(self.export_path).glob("*.ipa"))
                if ipa_files:
                    ipa_path = ipa_files[0]
                    print(f"📦 IPA created: {ipa_path}")
                    return str(ipa_path)
                else:
                    print("❌ No IPA file found after export")
                    return False
            else:
                print(f"❌ Export failed with code {result.returncode}")
                print(f"STDOUT: {result.stdout}")
                print(f"STDERR: {result.stderr}")
                return False
                
        except subprocess.TimeoutExpired:
            print("❌ Export timed out after 5 minutes")
            return False
        except Exception as e:
            print(f"❌ Export failed with exception: {e}")
            return False
    
    def upload_to_testflight(self, ipa_path, api_key_path, api_key_id, api_issuer_id):
        """
        Foundation-first: Upload IPA to TestFlight using App Store Connect API
        """
        print(f"🚀 Uploading {ipa_path} to TestFlight...")
        
        try:
            cmd = [
                "xcrun", "altool",
                "--upload-app",
                "--type", "ios",
                "--file", ipa_path,
                "--apiKey", api_key_id,
                "--apiIssuer", api_issuer_id
            ]
            
            print(f"📤 Running: {' '.join(cmd)}")
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
            
            if result.returncode == 0:
                print("🎉 Upload to TestFlight succeeded!")
                print("📱 Check TestFlight app on your iPhone in 5-10 minutes!")
                return True
            else:
                print(f"❌ Upload failed with code {result.returncode}")
                print(f"STDOUT: {result.stdout}")
                print(f"STDERR: {result.stderr}")
                return False
                
        except subprocess.TimeoutExpired:
            print("❌ Upload timed out after 10 minutes")
            return False
        except Exception as e:
            print(f"❌ Upload failed with exception: {e}")
            return False

def main():
    """
    Main function - Foundation-first command line interface
    """
    parser = argparse.ArgumentParser(description="iOS Export Automation Tool")
    parser.add_argument("--archive", required=True, help="Path to .xcarchive file")
    parser.add_argument("--apple-id", required=True, help="Apple ID email")
    parser.add_argument("--app-password", required=True, help="App-specific password")
    parser.add_argument("--team-id", required=True, help="Apple Developer Team ID")
    parser.add_argument("--bundle-id", required=True, help="App bundle identifier")
    parser.add_argument("--profile-name", required=True, help="Provisioning profile name")
    parser.add_argument("--api-key-path", help="Path to App Store Connect API key (.p8)")
    parser.add_argument("--api-key-id", help="App Store Connect API Key ID")
    parser.add_argument("--api-issuer-id", help="App Store Connect API Issuer ID")
    parser.add_argument("--upload", action="store_true", help="Upload to TestFlight after export")
    
    args = parser.parse_args()
    
    print("🚀 iOS Export Automation Tool")
    print("Foundation-first approach to iOS deployment")
    print("=" * 50)
    
    # Initialize automator
    automator = iOSExportAutomator(
        apple_id=args.apple_id,
        app_password=args.app_password,
        team_id=args.team_id,
        bundle_id=args.bundle_id
    )
    
    # Export archive to IPA
    ipa_path = automator.export_archive(args.archive, args.profile_name)
    
    if not ipa_path:
        print("❌ Export failed")
        sys.exit(1)
    
    # Upload to TestFlight if requested
    if args.upload and args.api_key_path and args.api_key_id and args.api_issuer_id:
        success = automator.upload_to_testflight(
            ipa_path=ipa_path,
            api_key_path=args.api_key_path,
            api_key_id=args.api_key_id,
            api_issuer_id=args.api_issuer_id
        )
        
        if not success:
            print("❌ Upload failed")
            sys.exit(1)
    
    print("🎉 iOS Export Automation completed successfully!")
    print("Foundation-first approach works!")

if __name__ == "__main__":
    main()