# Monitor switching

Optional module for switching all monitors to PC 1 or PC 2. Enable DDC/CI on each
monitor and configure [monitor-inputs.json](monitor-inputs.json).

Run the commands below from the repository root. Installers create commands in
`~/.local/bin` and desktop launchers without editing shell profiles. The dotfiles
profiles already add that directory to PATH; open a new terminal after installation.

## Windows

Download [ControlMyMonitor](https://www.nirsoft.net/utils/control_my_monitor.html)
and place `ControlMyMonitor.exe` in `%LOCALAPPDATA%\Programs\ControlMyMonitor`.
Set each monitor's `shortMonitorId` in the configuration.

```powershell
./modules/monitor-switching/windows/Install.ps1
Switch-Monitors 2 -WhatIf  # Preview
Switch-Monitors 2         # Use 1 for PC 1
```

Also creates **Switch to PC 1 / PC 2** Start Menu shortcuts.

## macOS (Apple Silicon)

```sh
brew install m1ddc jq
m1ddc display list detailed
```

Copy each monitor's **System UUID** into its `displayUuid` configuration field.

```sh
bash modules/monitor-switching/macos/install.sh
switch-monitors 1 --dry-run  # Preview
switch-monitors 1           # Use 2 for PC 2
```

Also creates **Switch to PC 1 / PC 2** apps in `~/Applications` for Spotlight or the Dock.
DDC communication errors return exit code 3 (switch unconfirmed) without an app
popup; check the displays manually. Other errors still alert.

Rerun the relevant installer after moving the checkout or updating desktop launchers.
