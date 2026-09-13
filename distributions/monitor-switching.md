# Monitor switching

Input values live in `monitor-inputs.json`. Enable DDC/CI in each monitor's settings.

## Windows

Download [ControlMyMonitor](https://www.nirsoft.net/utils/control_my_monitor.html)
and place `ControlMyMonitor.exe` in `%LOCALAPPDATA%\Programs\ControlMyMonitor`.

From the repository root, create **Switch to PC 1 / PC 2** shortcuts in your Start Menu Programs folder:

```powershell
./distributions/windows/Install-MonitorSwitch.ps1
```

With this repository's PowerShell profile installed, open a new tab:

```powershell
Switch-Monitors 2 -WhatIf  # Preview
Switch-Monitors 2          # Switch to PC 2; use 1 for PC 1
```

Without the profile, run `./distributions/windows/Switch-Monitors.ps1 2`.
Rerun the installer if you move the checkout.

## macOS (Apple Silicon)

```sh
brew install m1ddc jq
m1ddc display list detailed
```

Match each monitor by name/serial and copy its **System UUID** into `displayUuid`
in `monitor-inputs.json`. `shortMonitorId` is the identifier used by ControlMyMonitor.

From the repository root:

```sh
bash distributions/macos/install-monitor-switch.sh
```

Installs `~/.local/bin/switch-monitors`, adds its directory to PATH in your `.zshrc`
(respecting `ZDOTDIR`), and creates **Switch to PC 1 / PC 2** apps in `~/Applications`.
Find them in Spotlight or drag them to the Dock. Rerun the installer if you move the checkout.

In a new terminal:

```sh
switch-monitors 1 --dry-run
switch-monitors 1          # Switch to PC 1; use 2 for PC 2
```
