#!/usr/bin/env python3
"""
AppleDeploy Interactive Export Tool
Handles Apple ID prompts during iOS export process
Foundation-first approach with user interaction when needed
"""

import subprocess
import sys
import os
import time
import threading
import queue
from pathlib import Path

class InteractiveExportTool:
    """
    Interactive export tool that prompts user for Apple ID when needed
    Foundation-first approach: Let user handle authentication when Apple asks
    """
    
    def __init__(self):
        self.user_input_queue = queue.Queue()
        self.process = None
        
    def prompt_user_for_credentials(self, prompt_text):
        """
        Foundation-first: Prompt user for Apple ID credentials when Apple asks
        """
        print(f"\n🍎 APPLE AUTHENTICATION REQUIRED:")
        print(f"📋 {prompt_text}")
        print("=" * 50)
        
        if "Apple ID" in prompt_text or "username" in prompt_text.lower():
            apple_id = input("🔐 Enter your Apple ID: ")
            return apple_id
        elif "password" in prompt_text.lower():
            import getpass
            password = getpass.getpass("🔑 Enter your app-specific password: ")
            return password
        else:
            response = input(f"📝 {prompt_text}: ")
            return response
    
    def monitor_export_process(self, cmd):
        """
        Foundation-first: Monitor export process and handle interactive prompts
        """
        print("🚀 Starting interactive export process...")
        print("💡 We'll prompt you if Apple asks for authentication")
        print("")
        
        try:
            # Start xcodebuild process with interactive input
            self.process = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,
                universal_newlines=True
            )
            
            # Monitor output in separate thread
            output_thread = threading.Thread(target=self.monitor_output)
            output_thread.daemon = True
            output_thread.start()
            
            # Monitor for completion
            return_code = self.process.wait()
            
            if return_code == 0:
                print("✅ Export completed successfully!")
                return True
            else:
                print(f"❌ Export failed with code {return_code}")
                return False
                
        except Exception as e:
            print(f"❌ Export process failed: {e}")
            return False
    
    def monitor_output(self):
        """
        Foundation-first: Monitor process output and detect Apple prompts
        """
        while self.process and self.process.poll() is None:
            try:
                # Read output line by line
                line = self.process.stdout.readline()
                if line:
                    print(f"📋 {line.strip()}")
                    
                    # Detect Apple authentication prompts
                    if any(keyword in line.lower() for keyword in [
                        "apple id", "username", "password", "authentication",
                        "sign in", "login", "credentials"
                    ]):
                        # Prompt user for input
                        user_input = self.prompt_user_for_credentials(line.strip())
                        
                        # Send input to process
                        if self.process and self.process.stdin:
                            self.process.stdin.write(user_input + "\n")
                            self.process.stdin.flush()
                
                # Also check stderr for prompts
                if self.process.stderr:
                    err_line = self.process.stderr.readline()
                    if err_line:
                        print(f"⚠️ {err_line.strip()}")
                        
            except Exception as e:
                print(f"Error monitoring output: {e}")
                break
    
    def export_with_interaction(self, archive_path, export_path="./build"):
        """
        Foundation-first: Export archive with user interaction when needed
        """
        print("🍎 AppleDeploy Interactive Export")
        print("Foundation-first approach with user prompts")
        print("=" * 50)
        
        if not os.path.exists(archive_path):
            print(f"❌ Archive not found: {archive_path}")
            return False
        
        # Create export directory
        os.makedirs(export_path, exist_ok=True)
        
        # Create export.plist with automatic signing
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
        
        print("🚀 Starting export with interactive prompts...")
        print("💡 You'll be prompted if Apple asks for authentication")
        print("")
        
        # Run with interactive monitoring
        success = self.monitor_export_process(cmd)
        
        if success:
            # Find generated IPA
            ipa_files = list(Path(export_path).glob("*.ipa"))
            if ipa_files:
                print(f"📦 IPA created: {ipa_files[0]}")
                return str(ipa_files[0])
        
        return False

def main():
    """
    Main function for interactive export
    """
    import argparse
    
    parser = argparse.ArgumentParser(description="AppleDeploy Interactive Export")
    parser.add_argument("--archive", required=True, help="Path to .xcarchive file")
    parser.add_argument("--export-path", default="./build", help="Export directory")
    
    args = parser.parse_args()
    
    # Initialize interactive export tool
    export_tool = InteractiveExportTool()
    
    # Run interactive export
    ipa_path = export_tool.export_with_interaction(args.archive, args.export_path)
    
    if ipa_path:
        print("🎉 Interactive export completed successfully!")
        print(f"📱 IPA ready: {ipa_path}")
        
        # Ask user if they want to upload to TestFlight
        upload = input("\n🚀 Upload to TestFlight now? (y/n): ").lower().strip()
        
        if upload == 'y' or upload == 'yes':
            print("📤 Upload feature coming soon in AppleDeploy platform!")
            print("💡 For now, use Xcode Organizer or manual altool upload")
    else:
        print("❌ Interactive export failed")
        sys.exit(1)

if __name__ == "__main__":
    main()