<#
.SYNOPSIS
    KosigiUSB - USB forensics.
    Author:
    Huinholang
    
.DESCRIPTION
    Get some juicy information about USB devices from Computer.
    Please find below short query to search USB devices and files in CrowdStrike Falcon:
    aid=* (((event_simpleName=DcUsbDeviceConnected AND DevicePropertyDeviceDescription="USB Mass Storage Device" AND DeviceInstanceId="USB*" )) OR (event_simpleName="*written*" AND DiskParentDeviceInstanceId="USB*"))
    | eval matchfield=coalesce(DeviceInstanceId,DiskParentDeviceInstanceId)
    | table _time, name, UserName, ComputerName, FileName, TargetFileName, DeviceManufacturer, DeviceProduct
.EXAMPLE
    Start:
    PS C:\> Import-Module .\Get-KosigiUSB.ps1

    PS C:\> Get-KosigiUSB -UserName <UserName>
.NOTES
    Inspirations:
    https://www.sans.org/posters/windows-forensic-analysis/
    https://forensicswiki.xyz/wiki/index.php?title=USB
    https://www.tristiansforensicsecurity.com/2018/11/28/basic-usb-forensics-in-windows/
    
    Stay Geeky!
#>

function Get-KosigiUSB {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, ParameterSetName="UserName", Position = 0)]
        [String]$UserNameCMD
    )

    <# Get registry stuff
     1.Key identification:
     HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR
     HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB 
     2.Drive Letter and Volume Name:
     HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices
     3.Other
     General devices:
     HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR\
     USB Last Removal Date:
     HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum\USBSTOR\xxx\xxx\Properties\
     USB Last Arrival Date:
     HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum\USBSTOR\xxx\xxx\Properties\
     Printers:
     HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum\USBPRINT\
     USB Device Interface:
     HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\DeviceClasses\{a5dcbf10-6530-11d2-901f-00c04fb951ed}
     USB Device Classess:
     HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\DeviceClasses\{53f56307-b6bf-11d0-94f2-00a0c91efb8b}
     USB Portable:
     HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Portable Devices\Devices\
     Mounted by User:
     HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2
     #>
    $keys = @'
    HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum\USBPRINT
    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB
    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR
    HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\DeviceClasses\{a5dcbf10-6530-11d2-901f-00c04fb951ed}
    HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\DeviceClasses\{53f56307-b6bf-11d0-94f2-00a0c91efb8b}
    HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2
    HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Portable Devices\Devices
'@ -split '\r?\n'
 

    $UserName = $UserNameCMD
    $Destdir = "C:\Users\Public"
    $Destfile = "$Destdir\KosigiUSB-$UserName.reg"

    New-Item -ItemType "directory" -Path "$Destdir" -Name "KosigiUSB-$UserName"

    $keys | ForEach-Object {
        $i++
        & reg export $_ "$Destdir\KosigiUSB-$UserName\$i.reg"
        }
    # Merge this stuff
    'Windows Registry Editor Version 5.00' | Set-Content $Destfile
    Get-Content "$Destdir\KosigiUSB-$UserName\*.reg" | Where-Object {
    $_ -ne 'Windows Registry Editor Version 5.00'
    } | Add-Content $Destfile
    Move-Item -Path $Destfile -Destination "$Destdir\KosigiUSB-$UserName\"

    <# Get event stuff from log files
     1.First and last time: 
     path: \Windows\inf\setupapi.dev.log
     setupapi.dev.log – Device and driver installations
     setupapi.app.log – Application installations
     2.NTUSER.DAT:
     C:\Users\Default\NTUSER.DAT
     3. PnP Events:
     %systemroot%\System32\winevt\logs\System.evtx
     Interpretation
     Event ID: 20001 – Plug and Play driver
     install attempted
     Event ID 20001
     Timestamp
     Device information
     Device serial number
     Status (0 = no errors)
    #>

    # Get logs
    # Get setupapi.dev.log
    $Path = "$env:SYSTEMDRIVE\Windows\INF"
    Copy-Item $Path\setupapi.dev*.log -Destination $Destdir\KosigiUSB-$UserName

    # Get setupapi.setup.log
    Copy-Item $Path\setupapi.setup*.log -Destination $Destdir\KosigiUSB-$UserName

    # Get setupapi.offline.log
    Copy-Item $Path\setupapi.offline*.log -Destination $Destdir\KosigiUSB-$UserName

    # Get PnP Events
    Get-WinEvent -FilterHashtable @{
        LogName='System'
        ID=20001,10000,24576} | Out-File -FilePath $Destdir\KosigiUSB-$UserName\PnPEvents.txt


    # Compress this stuff
    Compress-Archive -Path $Destdir\KosigiUSB-$UserName -DestinationPath $Destdir\KosigiUSB-$UserName 
    Remove-Item $Destdir\KosigiUSB-$UserName -Recurse

}
