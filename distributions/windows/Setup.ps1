#Requires -RunAsAdministrator

# Utility Functions
function Add-Path($Path) {
    $Path = [Environment]::GetEnvironmentVariable("PATH", "Machine") + [IO.Path]::PathSeparator + $Path
    [Environment]::SetEnvironmentVariable( "Path", $Path, "Machine" )
}

function Sync-Path() {
    # Refreshes Path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Required PowerShell Modules
$requiredModules = @()

# Linked Files (Destination => Source)
$symlinks = @{
    "$PROFILE" = ".\distributions\windows\Profile.ps1"
    "$HOME\AppData\Local\nvim" = ".\nvim"
    "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\distributions\windows\windows_terminal\settings.json"
    "$HOME\AppData\Local\Microsoft\Windows Terminal\settings.json" = ".\distributions\windows\windows_terminal\settings.json"
    "$HOME\.gitconfig" = ".\distributions\windows\.gitconfig"
}

# Set working directory
$Root = $PSScriptRoot | Split-Path | Split-Path
Set-Location $Root
[Environment]::CurrentDirectory = $Root

# Set Path
Write-Host "Updating Path..."

Add-Path "C:\Program Files (x86)\Nmap"
Sync-Path

# Install dependencies
Write-Host "Installing missing dependencies..."

if (!(Get-Command "pwsh" -ErrorAction SilentlyContinue)) {
    winget install -e --id=Microsoft.PowerShell
}

if (!(Get-Command "git" -ErrorAction SilentlyContinue)) {
    winget install -e --id=Git.Git
}

if (!(Get-Command "starship" -ErrorAction SilentlyContinue)) {
    winget install -e --id Starship.Starship
}

if (!(Get-Command "choco" -ErrorAction SilentlyContinue)) {
    winget install -e --id=Chocolatey.Chocolatey
}

Sync-Path

# Choco Deps
if (!(Get-Command "zig" -ErrorAction SilentlyContinue)) {
    choco install -y zig
}

if (!(Get-Command "rg" -ErrorAction SilentlyContinue)) {
    choco install -y ripgrep
}

if (!(Get-Command "fd" -ErrorAction SilentlyContinue)) {
    choco install -y fd
}

if (!(Get-Command "nvim" -ErrorAction SilentlyContinue)) {
    choco install -y neovim
}

if (!(Get-Command "fzf" -ErrorAction SilentlyContinue)) {
    choco install -y fzf
}

if (!(Get-Command "nmap" -ErrorAction SilentlyContinue)) {
    choco install -y nmap
}

# Fonts
Write-Host "Installing Fonts..."

# Get all installed font families
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families

# Check if JetBrainsMono NF is installed
if ($fontFamilies -notcontains "JetBrainsMono NF") {
    # Download and install JetBrainsMono NF
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip", ".\JetBrainsMono.zip")

    Expand-Archive -Path ".\JetBrainsMono.zip" -DestinationPath ".\JetBrainsMono" -Force
    $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)

    $fonts = Get-ChildItem -Path ".\JetBrainsMono" -Recurse -Filter "*.ttf"
    foreach ($font in $fonts) {
        # Only install standard fonts (16 fonts instead of 90+)
        if ($font.Name -like "JetBrainsMonoNerdFont-*.ttf"){
            $destination.CopyHere($font.FullName, 0x10)
        }
    }

    Remove-Item -Path ".\JetBrainsMono" -Recurse -Force
    Remove-Item -Path ".\JetBrainsMono.zip" -Force
}

# Create Symbolic Links
Write-Host "Creating Symbolic Links..."
foreach ($symlink in $symlinks.GetEnumerator()) {
    Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}

# Install Required PowerShell Modules
Write-Host "Installing missing PowerShell Modules..."
foreach ($module in $requiredModules){
    if (!(Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue)) {
        Install-Module $module -Scope CurrentUser -Force
    }
}
