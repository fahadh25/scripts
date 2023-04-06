#Changelog-1.0
#CC repair put at end

cd $PSScriptRoot

#Local Admin add and remove Administrator user
New-LocalUser -Name "GraphicPeople" -FullName "GraphicPeople" -Description "Local Administrator User" -Password $(read-host -AsSecureString "Enter password for GraphicPeople") -PasswordNeverExpires
Add-LocalGroupMember -Group 'Administrators' -Member "graphicpeople"
Add-LocalGroupMember -Group 'Users' -Member "graphicpeople"

#Remote Desktop enable
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"


#Firewall Remote assistance and Desktop (private untick)
Set-NetFirewallRule -DisplayGroup "Remote Desktop" -Profile Public,Domain -Enabled True
Set-NetFirewallRule -DisplayGroup "Remote Assistance" -Profile Public,Domain -Enabled True

#Enable Other user option
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -name "HideFastUserSwitching" -value 0


#Enable SMB 1.0/CIFS client feature
Enable-WindowsOptionalFeature -Online -FeatureName "smbdirect" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Client" -All -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Deprecation" -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol-Server" -NoRestart

#Power Management
foreach( $scheme in Get-Content $PSScriptRoot\Power-Scheme.txt ) {
	powercfg /setdcvalueindex $scheme SUB_DISK DISKIDLE 000
	powercfg /setacvalueindex $scheme SUB_DISK DISKIDLE 000
	powercfg /setdcvalueindex $scheme SUB_SLEEP STANDBYIDLE 000
	powercfg /setacvalueindex $scheme SUB_SLEEP STANDBYIDLE 000
	powercfg /setacvalueindex $scheme SUB_SLEEP HYBRIDSLEEP 000
	powercfg /setdcvalueindex $scheme SUB_SLEEP HYBRIDSLEEP 000
	powercfg /setdcvalueindex $scheme SUB_SLEEP HIBERNATEIDLE 000
	powercfg /setacvalueindex $scheme SUB_SLEEP HIBERNATEIDLE 000
	powercfg /setacvalueindex $scheme SUB_SLEEP RTCWAKE 000
	powercfg /setdcvalueindex $scheme SUB_SLEEP RTCWAKE 000
	powercfg /setdcvalueindex $scheme SUB_PCIEXPRESS ASPM 000
	powercfg /setacvalueindex $scheme SUB_PCIEXPRESS ASPM 000
	powercfg /setacvalueindex $scheme SUB_VIDEO VIDEOIDLE 000
	powercfg /setdcvalueindex $scheme SUB_VIDEO VIDEOIDLE 000
}


#LAN/Ethernet setup
Disable-NetAdapterBinding -Name "Ethernet*" -DisplayName "Internet Protocol Version 6 (TCP/IPv6)"
Disable-NetAdapterBinding -Name "Ethernet*" -DisplayName "Microsoft LLDP*"
Disable-NetAdapterBinding -Name "Ethernet*" -DisplayName "QoS Packet*"
Disable-NetAdapterBinding -Name "Ethernet*" -DisplayName "Link-Layer Topology*"
Set-NetAdapterPowerManagement -Name "Ethernet*" -WakeOnMagicPacket Disabled -NoRestart

#Disable "Allow the computer to turn off this device to save power"
$ethname = (get-wmiobject win32_networkadapter -filter "netconnectionstatus = 2").Name
$ethpath = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\*" | Where-Object { $_.DriverDesc -like $ethname }).PSPath
Set-ItemProperty -Path $ethpath -Name "PnPCapabilities" -Value 25e


#font permission change
$acl = Get-Acl -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("BUILTIN\Users","FullControl",@("ObjectInherit","ContainerInherit"),"None","Allow")
$acl.SetAccessRule($rule)
$acl |Set-Acl -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"


##########Software installation#############

#Creative Cloud Install
cd "Creative_Cloud\Build" 
.\setup.exe
cd $PSScriptRoot

#Other software installation
foreach( $line in Get-Content "Software list.txt" ) {
	Start-Process -Wait -FilePath "$line" -ArgumentList "/qn","/norestart" -PassThru
}
copy "Cisco AnyConnect\bdwt.xml" "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile"



#Graphics driver update
foreach($gpu in Get-WmiObject Win32_VideoController) { echo $gpu.Description  > $PSScriptRoot\driver.txt }
foreach( $line in Get-Content driver.txt ) {
	cd "Graphics Driver\$line"
	Start-Process -Wait -FilePath .\*.exe -ArgumentList "/qn","/norestart" -PassThru
    cd $PSScriptRoot
}
Remove-Item -Path C:\driver.txt

#Dell WaveMaxx installation
$brand = wmic computersystem get manufacturer | Sort-Object | Select-String -Pattern "Dell"
if ( $null -ne $brand ){
	cd "WavesAudio MaxxAudioPro 2.0.54.0"
	.\install.exe
	cd $PSScriptRoot
}

#WinZIP installation
Copy-Item "WinZIP" "C:\WinZIP" -Recurse -Force
cd "C:\WinZIP\"
Start-Process -Wait -FilePath '.\Install.vbs' -ArgumentList "/qn" -PassThru
cd $PSScriptRoot

#Repair Creative Cloud
cd "C:\Program Files (x86)\Adobe\Adobe Creative Cloud\Utils\"
.\'Creative Cloud Uninstaller.exe'
cd $PSScriptRoot

############Rename Computer and Domain Join######################

$computer = Read-Host "Enter Computer name "
Add-Computer -Domain ap.corp.jwt.com -Force
Rename-Computer $computer -DomainCredential ap.corp.jwt.com\ -Force
Add-LocalGroupMember -Group 'Administrators' -Member "AP\BD-JWT-GRP-x.BDIT","AP\BD-JWT-GRP-IT"

$username = Read-Host "Enter device username (just press enter if n/a): "
if ( $username ){
	Add-LocalGroupMember -Group 'Remote Desktop Users' -Member $username
	Add-LocalGroupMember -Group 'Network Configuration Operators' -Member $username
}
$xuser = Read-Host "Enter X ac username (just press enter if no X account): "
if ( $xuser ){
	Add-LocalGroupMember -Group 'Administrators' -Member $xuser
}


#####Disbale Built-in Admin user########

Disable-LocalUser -Name "Administrator"
gpupdate /force
























