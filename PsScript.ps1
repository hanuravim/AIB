$name = $PSScriptRoot + "\" + $MyInvocation.MyCommand.Name

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$name`"" -Verb RunAs; exit }

New-Item –Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"
$Name = "AlwaysInstallElevated "
$value = "0"

New-ItemProperty -Path $registryPath -Name $name -Value $value ` -PropertyType DWORD -Force | Out-Null
