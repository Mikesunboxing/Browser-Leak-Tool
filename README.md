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

2. Copy and paste the script into Powershell as Admin.
