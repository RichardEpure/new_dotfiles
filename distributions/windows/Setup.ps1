#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [ValidateSet("All", "OpenCode", "Dotfiles")]
    [string]$Mode
)

$ErrorActionPreference = "Stop"

$yes = @("yes","y")
$no = @("no", "n")

$logPath = "$env:USERPROFILE/Setup.log"
"Old path: $([Environment]::GetEnvironmentVariable("Path", "Machine"))`n" | Out-File -FilePath $logPath -Append

# Utility Functions
function Add-Path($Path)
{
    $PathConent = [Environment]::GetEnvironmentVariable("Path", "Machine")

    # Add to PATH if it doesn't exist
    if ($null -ne $Path)
    {
        if (!($PathConent -split [IO.Path]::PathSeparator -contains $Path))
        {
            $NewPathContent = $PathConent + [IO.Path]::PathSeparator + $Path
            [Environment]::SetEnvironmentVariable( "Path", $NewPathContent, "Machine" )
        }
    }
}

function Sync-Path()
{
    # Refreshes Path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + [IO.Path]::PathSeparator + [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Get-Response($prompt)
{
    do
    {
        $answer = Read-Host $prompt, " (Y/N)"
    }
    until($no -contains $answer -or $yes -contains $answer)
    return $answer
}

function Select-InstallMode
{
    if ($Mode)
    {
        return $Mode
    }

    Write-Host "Select what to install:"
    Write-Host "1. All"
    Write-Host "2. Only OpenCode"
    Write-Host "3. Dotfiles only"
    while ($true)
    {
        switch (Read-Host "Choice")
        {
            "1" { return "All" }
            "2" { return "OpenCode" }
            "3" { return "Dotfiles" }
            default { Write-Warning "Enter 1, 2, or 3." }
        }
    }
}

function Install-OpenCodeConfig([string]$DotfilesRoot)
{
    $privateRoot = Join-Path (Split-Path -Parent $DotfilesRoot) "opencode-config"

    if (Test-Path -LiteralPath $privateRoot)
    {
        $repositoryRoot = & git -C $privateRoot rev-parse --show-toplevel 2>$null
        $expectedRoot = [IO.Path]::GetFullPath($privateRoot).TrimEnd([IO.Path]::DirectorySeparatorChar)
        if ($LASTEXITCODE -ne 0 -or
            -not [IO.Path]::GetFullPath($repositoryRoot).TrimEnd([IO.Path]::DirectorySeparatorChar).Equals(
                $expectedRoot,
                [StringComparison]::OrdinalIgnoreCase
            ))
        {
            throw "$privateRoot exists but is not a Git repository."
        }
        & git -C $privateRoot pull --ff-only
        if ($LASTEXITCODE -ne 0)
        {
            throw "Failed to update $privateRoot. Commit or stash local changes and retry."
        }
    }
    elseif (Get-Command gh -ErrorAction SilentlyContinue)
    {
        & gh repo clone RichardEpure/opencode-config $privateRoot
        if ($LASTEXITCODE -ne 0)
        {
            throw "Failed to clone the private OpenCode repository. Check GitHub authentication."
        }
    }
    else
    {
        & git clone git@github.com:RichardEpure/opencode-config.git $privateRoot
        if ($LASTEXITCODE -ne 0)
        {
            throw "Failed to clone the private OpenCode repository. Check SSH authentication."
        }
    }

    & (Join-Path $privateRoot "setup.ps1")
    if ($LASTEXITCODE -ne 0)
    {
        throw "OpenCode setup failed."
    }
}

$Root = $PSScriptRoot | Split-Path | Split-Path
$InstallMode = Select-InstallMode
if ($InstallMode -in @("All", "OpenCode"))
{
    Install-OpenCodeConfig $Root
}
if ($InstallMode -eq "OpenCode")
{
    return
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

# Dependencies
$wingetDependencies = @(
    "Microsoft.PowerShell"
    "Chocolatey.Chocolatey"
    "Starship.Starship"
    "ajeetdsouza.zoxide"
    "Typst.Typst"
    "Docker.DockerDesktop"
)
$chocoDependencies = @(
    "altsnap"
    "zig"
    "ripgrep"
    "fd"
    "neovim"
    "fzf"
    "nvm"
    "nerd-fonts-jetbrainsmono"
    "lazygit"
    "lazydocker"
    "jq"
)
$scoopDependencies = @(
    "yazi"
    "ninja"
    "7zip"
)
$requiredModules = @(
    "PSFzf"
)

# Extras
$wingetExtras = @(
    "AgileBits.1Password"
    "Microsoft.PowerToys"
    "voidtools.Everything"
    "lin-ycv.EverythingPowerToys"
    "MartiCliment.UniGetUI"
    "Discord.Discord"
    "Mozilla.Firefox"
    "Google.Chrome"
)

# Set working directory
Set-Location $Root
[Environment]::CurrentDirectory = $Root

# Set Path
Write-Host "Updating Path..."

Add-Path "C:\Program Files (x86)\Nmap"
Add-Path "C:\Program Files\Git\usr\bin" # So yazi has access to 'file'
Sync-Path

# Install dependencies
$answer = Get-Response "Install dependencies?"
if ($yes -contains $answer)
{

    Write-Host "Installing dependencies..."

    # Winget
    $installedWingetDeps = winget list | Out-String
    foreach ($dependency in $wingetDependencies)
    {
        if ($installedWingetDeps -notmatch $dependency)
        {
            winget install --id $dependency --exact --source winget --accept-source-agreements --accept-package-agreements
        }
    }

    Sync-Path

    # Choco
    $installedChocoDeps = (choco list --limit-output --id-only).Split("`n")
    foreach ($dependency in $chocoDependencies)
    {
        if ($installedChocoDeps -notcontains $dependency)
        {
            choco install -y $dependency
        }
    }

    # Scoop
    $installedScoopDeps = (scoop list) | Select-Object -ExpandProperty Name
    foreach ($dependency in $scoopDependencies)
    {
        if ($installedScoopDeps -notcontains $dependency)
        {
            scoop install $dependency
        }
    }
}

# Install extras
$answer = Get-Response "Install extras?"
if ($yes -contains $answer)
{
    Write-Host "Installing extras..."

    $installedWingetDeps = winget list | Out-String
    foreach ($extra in $wingetExtras)
    {
        if ($installedWingetDeps -notmatch $extra)
        {
            winget install --id $extra --exact --source winget --accept-source-agreements --accept-package-agreements
        }
    }
}

# Create Symbolic Links
Write-Host "Creating Symbolic Links..."
foreach ($symlink in $symlinks.GetEnumerator())
{
    Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}

$answer = Get-Response "Install PowerShell Modules?"
if ($yes -contains $answer)
{
    # Install Required PowerShell Modules
    Write-Host "Installing missing PowerShell Modules..."
    foreach ($module in $requiredModules)
    {
        if (!(Get-Module -ListAvailable -Name $module -ErrorAction SilentlyContinue))
        {
            Install-Module $module -Scope CurrentUser -Force
        }
    }
}
