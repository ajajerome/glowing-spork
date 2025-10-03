#!/usr/bin/env python3
"""
Enhanced Interactive Export Tool for AppleDeploy
Advanced user prompts for Apple ID authentication during iOS export
Foundation-first approach with superior UX
"""

import subprocess
import sys
import os
import time
import threading
import queue
import re
import getpass
from pathlib import Path
import json

class EnhancedInteractiveExport:
    """
    Enhanced interactive export with smart Apple ID prompt detection
    Foundation-first UX: Clear, helpful prompts when Apple asks for authentication
    """
    
    def __init__(self):
        self.process = None
        self.export_logs = []
        self.credentials_cache = {}
        
    def display_welcome(self):
        """
        Foundation-first: Clear welcome message explaining the process
        """
        print("🍎 AppleDeploy Enhanced Interactive Export")
        print("=" * 60)
        print("💡 How this works:")
        print("   1. We start the export process automatically")
        print("   2. If Apple asks for credentials, we'll prompt you")
        print("   3. You enter your Apple ID info when needed")
        print("   4. We handle the rest automatically")
        print("")
        print("🔐 What you might need:")
        print("   • Your Apple ID (same as App Store login)")
        print("   • App-specific password (we'll help you create one)")
        print("   • Just follow our prompts - we'll guide you!")
        print("=" * 60)
        print("")
    
    def detect_apple_prompt_type(self, text):
        """
        Foundation-first: Intelligently detect what Apple is asking for
        """
        text_lower = text.lower()
        
        # Apple ID / Username prompts
        if any(keyword in text_lower for keyword in [
            "apple id", "username", "user name", "email", "account"
        ]):
            return "apple_id"
        
        # Password prompts
        elif any(keyword in text_lower for keyword in [
            "password", "app-specific", "app specific", "authentication"
        ]):
            return "password"
        
        # Two-factor authentication
        elif any(keyword in text_lower for keyword in [
            "verification", "2fa", "two-factor", "code", "verify"
        ]):
            return "2fa_code"
        
        # Team selection
        elif any(keyword in text_lower for keyword in [
            "team", "choose", "select"
        ]):
            return "team_selection"
        
        return "unknown"
    
    def prompt_for_apple_id(self):
        """
        Foundation-first: User-friendly Apple ID prompt
        """
        print("\n🍎 APPLE ID REQUIRED")
        print("─" * 30)
        print("💡 Apple is asking for your Apple ID")
        print("   This is the same email you use for App Store/Developer Portal")
        print("")
        
        if "apple_id" in self.credentials_cache:
            cached_id = self.credentials_cache["apple_id"]
            use_cached = input(f"🔄 Use cached Apple ID ({cached_id})? (y/n): ").lower().strip()
            if use_cached in ['y', 'yes', '']:
                return cached_id
        
        apple_id = input("📧 Enter your Apple ID: ").strip()
        self.credentials_cache["apple_id"] = apple_id
        return apple_id
    
    def prompt_for_password(self):
        """
        Foundation-first: User-friendly password prompt with guidance
        """
        print("\n🔑 APP-SPECIFIC PASSWORD REQUIRED")
        print("─" * 40)
        print("💡 Apple is asking for an app-specific password")
        print("   This is NOT your regular Apple ID password!")
        print("")
        print("📋 How to create one (if you don't have it):")
        print("   1. Go to appleid.apple.com")
        print("   2. Sign in → Security section")
        print("   3. Generate Password → Name it 'AppleDeploy'")
        print("   4. Copy the xxxx-xxxx-xxxx-xxxx format")
        print("")
        
        password = getpass.getpass("🔐 Enter app-specific password: ").strip()
        return password
    
    def prompt_for_2fa_code(self):
        """
        Foundation-first: 2FA code prompt
        """
        print("\n📱 TWO-FACTOR AUTHENTICATION")
        print("─" * 35)
        print("💡 Apple sent a verification code to your devices")
        print("   Check your iPhone, iPad, or Mac for the code")
        print("")
        
        code = input("🔢 Enter 6-digit verification code: ").strip()
        return code
    
    def prompt_for_team_selection(self, text):
        """
        Foundation-first: Team selection prompt
        """
        print("\n👥 TEAM SELECTION")
        print("─" * 20)
        print("💡 Apple is asking you to choose a development team")
        print(f"📋 Options: {text}")
        print("")
        
        selection = input("🎯 Enter your choice (number or team name): ").strip()
        return selection
    
    def handle_apple_prompt(self, prompt_text):
        """
        Foundation-first: Smart prompt handling based on Apple's request
        """
        prompt_type = self.detect_apple_prompt_type(prompt_text)
        
        if prompt_type == "apple_id":
            return self.prompt_for_apple_id()
        elif prompt_type == "password":
            return self.prompt_for_password()
        elif prompt_type == "2fa_code":
            return self.prompt_for_2fa_code()
        elif prompt_type == "team_selection":
            return self.prompt_for_team_selection(prompt_text)
        else:
            # Generic prompt for unknown requests
            print(f"\n🍎 APPLE REQUEST")
            print("─" * 20)
            print(f"💡 Apple is asking: {prompt_text}")
            return input("📝 Your response: ").strip()
    
    def monitor_export_with_smart_prompts(self, cmd):
        """
        Foundation-first: Monitor export with intelligent prompt detection
        """
        print("🚀 Starting enhanced interactive export...")
        print("💡 We'll guide you through any Apple authentication requests")
        print("")
        
        try:
            self.process = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,  # Combine stdout and stderr
                text=True,
                bufsize=1,
                universal_newlines=True
            )
            
            # Monitor output line by line
            while True:
                line = self.process.stdout.readline()
                
                if not line:
                    break
                
                line = line.strip()
                if line:
                    print(f"📋 {line}")
                    self.export_logs.append(line)
                    
                    # Detect if Apple is asking for input
                    if any(indicator in line.lower() for indicator in [
                        "enter", "input", "password", "apple id", "username",
                        "verification", "choose", "select", ":"
                    ]):
                        # This might be a prompt - handle it
                        user_response = self.handle_apple_prompt(line)
                        
                        if user_response and self.process.stdin:
                            self.process.stdin.write(user_response + "\n")
                            self.process.stdin.flush()
                            print(f"✅ Sent response to Apple")
            
            # Wait for process completion
            return_code = self.process.wait()
            
            if return_code == 0:
                print("\n🎉 Export completed successfully!")
                return True
            else:
                print(f"\n❌ Export failed with code {return_code}")
                return False
                
        except Exception as e:
            print(f"❌ Export process failed: {e}")
            return False
    
    def export_with_enhanced_interaction(self, archive_path, export_path="./build"):
        """
        Foundation-first: Enhanced export with superior user experience
        """
        self.display_welcome()
        
        if not os.path.exists(archive_path):
            print(f"❌ Archive not found: {archive_path}")
            print("💡 Make sure you've downloaded the archive from GitHub Actions")
            return False
        
        print(f"📦 Found archive: {archive_path}")
        
        # Create export directory
        os.makedirs(export_path, exist_ok=True)
        
        # Create optimized export.plist
        export_plist = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>MW98Z2Q68W</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>"""
        
        with open("export.plist", "w") as f:
            f.write(export_plist)
        
        print("✅ export.plist created with automatic signing")
        
        # Prepare xcodebuild command
        cmd = [
            "xcodebuild",
            "-exportArchive", 
            "-archivePath", archive_path,
            "-exportPath", export_path,
            "-exportOptionsPlist", "./export.plist"
        ]
        
        # Run with enhanced interactive monitoring
        success = self.monitor_export_with_smart_prompts(cmd)
        
        if success:
            # Find generated IPA
            ipa_files = list(Path(export_path).glob("*.ipa"))
            if ipa_files:
                ipa_path = ipa_files[0]
                print(f"📱 IPA created: {ipa_path}")
                
                # Ask about TestFlight upload
                upload = input("\n🚀 Upload to TestFlight now? (y/n): ").lower().strip()
                if upload in ['y', 'yes']:
                    print("📤 TestFlight upload coming next!")
                    return str(ipa_path)
                
                return str(ipa_path)
        
        return False

def main():
    """
    Enhanced interactive export main function
    """
    import argparse
    
    parser = argparse.ArgumentParser(description="AppleDeploy Enhanced Interactive Export")
    parser.add_argument("--archive", required=True, help="Path to .xcarchive file")
    parser.add_argument("--export-path", default="./build", help="Export directory")
    
    args = parser.parse_args()
    
    # Initialize enhanced export tool
    export_tool = EnhancedInteractiveExport()
    
    # Run enhanced interactive export
    result = export_tool.export_with_enhanced_interaction(args.archive, args.export_path)
    
    if result:
        print("\n🎉 AppleDeploy Enhanced Interactive Export SUCCESS!")
        print("📱 Your app is ready for TestFlight!")
        print("🚀 Foundation-first approach with interactive prompts works!")
    else:
        print("\n❌ Export failed")
        print("💡 Check the logs above for details")
        sys.exit(1)

if __name__ == "__main__":
    main()