# Browser Leak Tool

A lightweight PowerShell utility designed to prevent browser DNS leaks, enforce router-level DNS resolution, and manage Windows policy settings across all major browsers—without interfering with static IP configurations.

---

## Features

- **DNS Leak Prevention**: Disables internal browser DoH (DNS-over-HTTPS) to prevent queries from bypassing local network policies.
- **Smart Adapter Handling**: Automatically detects whether network adapters use DHCP or Static IPs, preserving custom IP/subnet settings while enforcing router DNS on DHCP adapters.
- **Multi-Browser Support**: Configures system policies for:
  - Google Chrome
  - Microsoft Edge
  - Brave
  - Vivaldi
  - Opera
  - DuckDuckGo Browser
  - Chromium
  - Mozilla Firefox
- **OS-Level Tuning**: Disables Windows Auto-DoH to unify system and browser DNS resolution.
- **Reversion / Restore Option**: Includes a built-in clean removal process to revert all Windows and browser policies back to default settings.

---

## Requirements

- **Operating System**: Windows 10 / Windows 11 / Windows Server
- **Privileges**: Administrator rights (required for modifying `HKLM` registry policies and network adapter settings)

---

## Quick Start

### Option 1: Run via PowerShell (Recommended)

1. Open PowerShell as **Administrator**:
   - Press `Win + X` and select **Terminal (Admin)** or **Windows PowerShell (Admin)**.

2. Copy and paste the script into Powershell as Admin. Or Download the ps1 file here https://github.com/Mikesunboxing/Browser-Leak-Tool/blob/main/Browser_Leak_Tool.ps1 and run as Admin in Powershell.


## How It Works

### Option 1: Apply Policies
Network Adapters: Scans for active IPv4 adapters (Status = Up).

If DHCP is enabled, it resets DNS server addresses to inherit directly from your router.

If a Static IP is detected, it leaves the configuration untouched.

Registry Hardening: Writes Group Policy keys under HKLM:\SOFTWARE\Policies to turn off internal browser DoH engines and ensure native OS resolver usage.

Cache Refresh: Flushes system-level DNS resolver caches (ipconfig /flushdns).

### Option 2: Remove Policies
Clears applied registry policy keys for all supported browsers.

Re-enables system default Auto-DoH settings.

Flushes DNS caches and renews DHCP IP leases (ipconfig /renew).

### Option 3: Exit Script
Now close the Powershell Window

Disclaimer
Provided for personal or business use. Use at your own risk. Always verify network policies within your organization before applying system-wide registry modifications.
