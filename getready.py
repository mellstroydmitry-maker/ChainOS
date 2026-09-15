#!/usr/bin/env python3
import os
import sys
import subprocess
import urllib.request

def run_command(command, use_sudo=False):
    """Helper function to execute system commands safely."""
    if use_sudo and os.geteuid() != 0:
        command = ["sudo"] + command
    
    print(f"-> Running: {' '.join(command)}")
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    # 1. Ensure the script is run with sudo privileges
    if os.geteuid() != 0:
        print("This script modifies system configurations and must be run with sudo privileges.", file=sys.stderr)
        print("Please rerun using: sudo python3 getready.py", file=sys.stderr)
        sys.exit(1)

    # Get the actual user username (since os.getlogin() or $USER might point to 'root' under sudo)
    real_user = os.environ.get("SUDO_USER", os.getlogin())

    print("=== Updating package lists ===")
    run_command(["apt", "update"])

    print("\n=== Installing ADB, Fastboot, and system utilities ===")
    packages = [
        "android-tools-adb", "android-tools-fastboot",
        "git", "curl", "wget", "unzip", "zip", "tar", 
        "build-essential", "libssl-dev", "pkg-config", "libusb-1.0-0-dev"
    ]
    run_command(["apt", "install", "-y"] + packages)

    print("\n=== Setting up udev rules for Android devices ===")
    udev_url = "https://githubusercontent.com"
    udev_path = "/etc/udev/rules.d/51-android.rules"
    
    try:
        print(f"Downloading udev rules from {udev_url}...")
        urllib.request.urlretrieve(udev_url, udev_path)
    except Exception as e:
        print(f"Failed to download udev rules: {e}", file=sys.stderr)
        sys.exit(1)

    print("\n=== Setting correct permissions on udev rules ===")
    # 0o644 is equivalent to rw-r--r-- (readable by all, writable by root)
    os.chmod(udev_path, 0o644)

    print(f"\n=== Adding user '{real_user}' to the plugdev group ===")
    run_command(["usermod", "-aG", "plugdev", real_user])

    print("\n=== Restarting the udev service ===")
    run_command(["udevadm", "control", "--reload-rules"])
    run_command(["service", "udev", "restart"])

    print("\n" + "="*57)
    print(" Everything is ready! Installed utility versions:")
    subprocess.run(["adb", "--version"])
    subprocess.run(["fastboot", "--version"])
    print("="*57)
    print("IMPORTANT: To apply group changes, restart your PC")
    print(f"or run the following command in a new terminal: newgrp plugdev")
    print("="*57)

if __name__ == "__main__":
    main()
