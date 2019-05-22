New-Item –Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer"
New-ItemProperty "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 0 -PropertyType "DWord"
