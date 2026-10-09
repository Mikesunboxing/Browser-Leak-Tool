# Browser Leak Tool

A lightweight, scriptless Windows registry utility developed by **Mikesunboxing LTD** to force web browsers and system apps to strictly adhere to local router network/DNS settings and prevent DNS or proxy leaks.

---

## Overview

Modern web browsers often bypass local router DNS configurations by utilizing internal **Secure DNS / DNS-over-HTTPS (DoH)** or allowing per-browser proxy configurations. 

**Browser Leak Tool** enforces system-wide enterprise policies via `HKEY_LOCAL_MACHINE` (HKLM) to:
1. Force all major web browsers to route traffic strictly through system-level proxy/network configurations.
2. Completely disable internal browser DoH resolvers, forcing query resolution to remain on your local network/router DNS settings.
3. Lock proxy settings in the Windows Control Panel to prevent user overrides.

---

## Supported Software

- **Google Chrome**
- **Microsoft Edge**
- **Mozilla Firefox**
- **Brave Browser**
- **Vivaldi Browser**
- **Opera Browser**
- **DuckDuckGo Windows App**
- **Generic Chromium Forks & Web Wrappers**
- **Windows System Network (Internet Explorer / Control Panel Policy)**

---

## File Structure

- `Browser_Leak_Tool_Apply.reg` — Enforces machine-wide DNS leak prevention and proxy mapping.
- `Browser_Leak_Tool_Remove.reg` — Clears applied enterprise policies and restores default browser behavior.

---

## User Guide & Installation

### Option 1: Apply Leak Prevention Policies

1. Download or clone this repository to your local machine.
2. Locate `Browser_Leak_Tool_Apply.reg`.
3. Right-click the file and select **Merge** (or double-click it).
4. Click **Yes** when prompted by User Account Control (UAC) and accept the Registry Editor confirmation.
5. Restart your web browsers for the policies to take effect immediately.

### Option 2: Verify Policy Status

You can verify that the policies are active by checking the enterprise policy engine in your respective browser:

- **Chrome / Brave / Vivaldi / Opera / Chromium**: Navigate to `chrome://policy` and confirm `DnsOverHttpsMode` and `ProxyMode` are set to `off` and `system`.
- **Microsoft Edge**: Navigate to `edge://policy`.
- **Mozilla Firefox**: Navigate to `about:policies` and verify `DNSOverHTTPS` is disabled.

### Option 3: Remove Policies / Restore Defaults

If you need to revert changes and allow browsers to manage their own DNS/proxy settings again:

1. Locate `Browser_Leak_Tool_Remove.reg`.
2. Right-click the file and select **Merge**.
3. Click **Yes** on the UAC prompt.
4. Restart your browsers or click **Reload policies** on your browser’s policy page (`chrome://policy` / `about:policies`).

---

## Raw Registry Reference

<details>
<summary>Click to view Apply Script (Browser_Leak_Tool_Apply.reg)</summary>

```registry
Windows Registry Editor Version 5.00

; =========================================================
; 1. WINDOWS SYSTEM NETWORK (MACHINE-WIDE / ALL USERS)
; Prevents users from overriding system proxy options in Control Panel.
; =========================================================
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Control Panel]
"Proxy"=dword:00000001

; =========================================================
; 2. MOZILLA FIREFOX (MACHINE-WIDE)
; Forces System Proxy (5) and disables DNS-over-HTTPS (0).
; =========================================================
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox]
"ProxyServerMode"=dword:00000005

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS]
"Enabled"=dword:00000000

; =========================================================
; 3. GOOGLE CHROME (MACHINE-WIDE)
; =========================================================
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome]
"ProxyMode"="system"
"DnsOverHttpsMode"="off"

; =========================================================
; 4. MICROSOFT EDGE (MACHINE-WIDE)
; =========================================================
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge]
"ProxyMode"="system"
"DnsOverHttpsMode"="off"

; =========================================================
; 5. BRAVE BROWSER (MACHINE-WIDE)
; =========================================================
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\BraveSoftware\Brave]
"ProxyMode"="system"
"DnsOverHttpsMode"="off"

; =========================================================
; 6. VIVALDI BROWSER (MACHINE-WIDE)
; =========================================================
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Vivaldi]
"ProxyMode"="system"
"DnsOverHttpsMode"="off"

; =========================================================
; 7. OPERA BROWSER (MACHINE-WIDE)
; =========================================================
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Opera]
"ProxyMode"="system"
"DnsOverHttpsMode"="off"

; =========================================================
; 8. GENERIC CHROMIUM & DUCKDUCKGO WINDOWS APP (MACHINE-WIDE)
; Catches unlisted Chromium forks and web-app wrappers.
; =========================================================
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Chromium]
"ProxyMode"="system"
"DnsOverHttpsMode"="off"
