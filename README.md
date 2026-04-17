# Network Adapter Toggler (AHK v2)

A lightweight, compact Windows utility built with **AutoHotkey v2** to manage network interfaces. This tool allows you to quickly view, enable, or disable network adapters (Wi-Fi, Ethernet, etc.) through a simple graphical interface.

## Features

* **List All Adapters:** Displays all network interfaces, including those currently disabled or disconnected.
* **Detailed Information:** Shows the Windows "friendly" name, the hardware manufacturer/model, and the current connection status.
* **One-Click Management:** Buttons to Enable or Disable the selected adapter instantly.
* **Administrator Elevation:** Automatically requests admin privileges (required to modify system network states).
* **Compact UI:** Optimized professional layout that stays on top of your workflow without cluttering the screen.

## How It Works

The application uses:
1.  **WMI (Windows Management Instrumentation):** To query deep system information about network hardware.
2.  **Netsh:** Executes native Windows shell commands to toggle adapter states safely.

## Requirements

* **Windows 10 / 11**
* **AutoHotkey v2.0+** installed.

## Usage

1.  Run the script (`.ahk` file).
2.  Accept the User Account Control (UAC) prompt to grant Administrator privileges.
3.  Select a network adapter from the list.
4.  Click **Habilitar (Enable)** or **Deshabilitar (Disable)**.
5.  The list will automatically refresh after a short delay to reflect the new status.

## Technical Notes

The core command used for toggling states is:
```autohotkey
netsh interface set interface name="ADAPTER_NAME" admin=enabled|disabled
