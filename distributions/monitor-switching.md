# Monitor switching

Input values live in `monitor-inputs.json`. Enable DDC/CI in each monitor's settings.

## Windows

Download [ControlMyMonitor](https://www.nirsoft.net/utils/control_my_monitor.html)
and place `ControlMyMonitor.exe` in `%LOCALAPPDATA%\Programs\ControlMyMonitor`.

From the repository root, create **Switch to PC 1 / PC 2** desktop shortcuts:

```powershell
./distributions/windows/Install-MonitorSwitch.ps1
```

With this repository's PowerShell profile installed, open a new tab:

```powershell
Switch-Monitors 2 -WhatIf  # Preview
Switch-Monitors 2          # Switch to PC 2; use 1 for PC 1
```

Without the profile, run `./distributions/windows/Switch-Monitors.ps1 2`.
Pin the shortcuts to Start for one-click access. Rerun the installer if you move the checkout.

## macOS (Apple Silicon)

```sh
brew install m1ddc jq
m1ddc display list detailed
```

Match each monitor by name/serial and copy its **System UUID** into `displayUuid`
in `monitor-inputs.json`. `shortMonitorId` is the identifier used by ControlMyMonitor.

Add to `~/.zshrc`, using your checkout path, then open a new terminal:

```sh
switch-monitors() { /bin/bash "$HOME/path/to/new_dotfiles/distributions/macos/switch-monitors.sh" "$@"; }
switch-monitors 1 --dry-run
switch-monitors 1          # Switch to PC 1; use 2 for PC 2
```

For clickable actions, create **Switch to PC 1 / PC 2** in Shortcuts, each with
**Run Shell Script** using the appropriate number:

```sh
/bin/bash "$HOME/path/to/new_dotfiles/distributions/macos/switch-monitors.sh" 1
```

Enable **Pin in Menu Bar** in each shortcut's details.

## Test

Wake both computers and connect the dock. From PC 1, switch to PC 2; from PC 2,
switch back to PC 1. Confirm all three monitors follow, then repeat with shortcuts.
If one fails, note the monitor, direction, and command output; restore its input manually.
