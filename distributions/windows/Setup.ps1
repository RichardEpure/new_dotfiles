#Requires -RunAsAdministrator

$logPath = "$env:USERPROFILE/Setup.log"
"Old path: $([Environment]::GetEnvironmentVariable("Path", "Machine"))`n" | Out-File -FilePath $logPath -Append

# Utility Functions
function Add-Path($Path) {
    $PathConent = [Environment]::GetEnvironmentVariable("Path", "Machine")

    # Add to PATH if it doesn't exist
    if ($null -ne $Path) {
        if (!($PathConent -split [IO.Path]::PathSeparator -contains $Path)) {
            $NewPathContent = $PathConent + $Path + [IO.Path]::PathSeparator
            [Environment]::SetEnvironmentVariable( "Path", $NewPathContent, "Machine" )
        }
    }
}

function Sync-Path() {
    # Refreshes Path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Linked Files (Destination => Source)
$symlinks = @{
    "$PROFILE" = ".\distributions\windows\Profile.ps1"
    "$HOME\.gitignore" = ".\.globalignore"
    "$HOME\AppData\Local\nvim" = ".\nvim"
    "$HOME\AppData\Local\nvim_minimal" = ".\nvim_minimal"
    "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\distributions\windows\windows_terminal\settings.json"
    "$HOME\AppData\Local\Microsoft\Windows Terminal\settings.json" = ".\distributions\windows\windows_terminal\settings.json"
    "$HOME\.gitconfig" = ".\distributions\windows\.gitconfig"
    "$HOME\AppData\Roaming\AltSnap\AltSnap.ini" = ".\distributions\windows\AltSnap.ini"
    "$HOME\AppData\Roaming\yazi\config" = ".\yazi"
}

# Winget dependencies
$wingetDependencies = @(
    "Chocolatey.Chocolatey"
    "Microsoft.PowerShell"
    "Git.Git"
    "Starship.Starship"
    "ajeetdsouza.zoxide"
)

# Choco dependencies
$chocoDependencies = @(
    "altsnap"
    "zig"
    "ripgrep"
    "fd"
    "neovim"
    "neovide"
    "fzf"
    "nmap"
    "nvm"
    "nerd-fonts-jetbrainsmono"
    "lazygit"
    "lazydocker"
    "jq"
)

# Scoop dependencies
$scoopDependencies = @(
    "yazi"
    "ninja"
    "7zip"
)

# Required PowerShell Modules
$requiredModules = @(
    "PSFzf"
)

# Set working directory
$Root = $PSScriptRoot | Split-Path | Split-Path
Set-Location $Root
[Environment]::CurrentDirectory = $Root

# Set Path
Write-Host "Updating Path..."

Add-Path "C:\Program Files (x86)\Nmap"
Add-Path "C:\Program Files\Git\usr\bin" # So yazi has access to 'file'
Sync-Path

# Install dependencies
Write-Host "Installing dependencies..."

# Winget
$installedWingetDeps = winget list | Out-String
foreach ($dependency in $wingetDependencies) {
    if ($installedWingetDeps -notmatch $dependency) {
        winget install -e --id $dependency
    }
}

Sync-Path

# Choco
$installedChocoDeps = (choco list --limit-output --id-only).Split("`n")
foreach ($dependency in $chocoDependencies) {
    if ($installedChocoDeps -notcontains $dependency) {
        choco install -y $dependency
    }
}

# Scoop
$installedScoopDeps = (scoop list) | Select-Object -ExpandProperty Name
foreach ($dependency in $scoopDependencies) {
    if ($installedScoopDeps -notcontains $dependency) {
        scoop install $dependency
    }
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
