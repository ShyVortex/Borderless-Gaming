$ErrorActionPreference = "Stop"

# Root of the repo
$root = (Get-Item $PSScriptRoot).Parent.FullName
$csproj = "$root\BorderlessGaming\BorderlessGaming.csproj"
$steamLibs = "$root\SteamLibs"
$outDir = "$root\BorderlessGaming\bin\Release\net8.0-windows\win-x64\publish"

# Make sure the output folder exists
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

# --- Copy SteamLibs to output ---
if (Test-Path $steamLibs) {
    Write-Host "Copying SteamLibs to output..."
    Copy-Item "$steamLibs\*" $outDir -Recurse -Force
} else {
    Write-Warning "SteamLibs folder not found at $steamLibs"
}

# --- Run Bebop compiler ---
& bebopc

# --- Restore and publish ---
& dotnet restore "$csproj"
& dotnet publish "$csproj" -c Release -r win-x64 -o "$outDir"

# --- Build installer with Inno Setup ---
$issFile = "$root\Installers\BorderlessGaming_Standalone_Admin.iss"
if (Test-Path $issFile) {
    & iscc $issFile
} else {
    Write-Warning "Inno Setup script not found: $issFile"
}
