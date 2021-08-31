# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
$ErrorActionPreference	= 'Stop';

$packageSearch		= 'KeePass Password Safe*'
$KeePassPath		= ''

if ([array]$key = Get-UninstallRegistryKey -SoftwareName $packageSearch) {
  $KeePassPath = $key.InstallLocation
}

if ([string]::IsNullOrEmpty($KeePassPath)) {
  Write-Verbose "Cannot find '$packageSearch' in Add / Remove Programs or Programs and Features."
  Write-Verbose "Searching '$env:ChocolateyToolsLocation' for portable install..."
  $portPath = Join-Path -Path $env:ChocolateyToolsLocation -ChildPath "keepass"
  $KeePassPath = Get-ChildItem -Directory "$portPath*" -ErrorAction SilentlyContinue

  if ([string]::IsNullOrEmpty($KeePassPath)) {
    Write-Verbose "Searching '$env:Path' for unregistered install..."
    $installFullName = Get-Command -Name keepass -ErrorAction SilentlyContinue
    if ($installFullName) {
      $KeePassPath = Split-Path $installFullName.Path -Parent
    }
  }
}

if ([string]::IsNullOrEmpty($KeePassPath)) {
  Write-Error -Message 'Cannot find Keepass! Exiting now as it''s needed to remove the plugin.' -ErrorAction Stop
}

Write-Host "Found Keepass install location at '$KeePassPath'."

$KeePassPluginPath	= 'Plugins'
$KeePassPluginName	= 'KeePassBrowserImporter.plgx'
$destPluginPath		= "$(Join-Path -Path $KeePassPath -ChildPath $KeePassPluginPath)"
$destFileFullPath	= "$(Join-Path -Path $destPluginPath -ChildPath $KeePassPluginName)"

if (Test-Path $destFileFullPath) {
  Remove-Item -Path $destFileFullPath -Force
}
