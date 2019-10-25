param (
    [string] $paths_target_file_path,
    [string] $destDir,
    [switch] $override
)

# Workaround that $PSScriptRoot is not support on ps version 2
If ($PSVersiontable.PSVersion.Major -le 2) {$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path}

if([string]::IsNullOrEmpty($paths_target_file_path))
{
    $paths_target_file_path = Join-Path $PSScriptRoot "paths.targets"
}

if([string]::IsNullOrEmpty($destDir))
{
    $destDir = $PSScriptRoot
}

if($override)
{
    Remove-Item (join-path $destDir "ZLib") -Recurse -Force -ErrorAction SilentlyContinue
}
elseif (Test-Path (Join-Path $destDir "ZLib") -PathType Container)
{
    return
}

Write-Host "Downloading ZLIB"
Write-Host "paths_target_file_path:$paths_target_file_path"
Write-Host "destDir:$destDir"
Write-Host "override:$override"

[xml] $buildConfig = Get-Content $paths_target_file_path
$version = $buildConfig.Project.PropertyGroup.ZLibVersion

$zip_path = Join-Path $PSScriptRoot "ZLib.zip"
$release_url = "https://github.com/PowerShell/zlib/releases/download/$version/zlib.zip"
Write-Host "release_url:$release_url"

Remove-Item $zip_path -Force -ErrorAction SilentlyContinue
Invoke-WebRequest -Uri $release_url -OutFile $zip_path 
if(-not (Test-Path $zip_path))
{
    throw "failed to download ZLIB zip file"
}

Expand-Archive -Path $zip_path -DestinationPath $destDir -Force -ErrorAction SilentlyContinue -ErrorVariable e
if($e -ne $null)
{
    throw "Error when expand zip file"
}

Remove-Item $zip_path -Force -ErrorAction SilentlyContinue

Write-Host "Succesfully downloaded ZLIB"