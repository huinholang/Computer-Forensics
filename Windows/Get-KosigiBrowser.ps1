<#
.SYNOPSIS
    KosigiBrowser - Web browser forensics.
    Author:
    Huinholang (☞ﾟヮﾟ)☞

.DESCRIPTION
    Find some juicy stuff from web browsers (Google Chrome and MS Edge): history, bookmarks, session, extensions, cookies. All data will be packed and copied
    to the 'C:\Users\Public' directory.
.EXAMPLE
    Start:
    PS C:\> Import-Module .\Get-KosigiBrowser.ps1

    Get information from Google Chrome and MS Edge:
    PS C:\> Get-KosigiBrowser -UserName ZXC123

    Get infotmations from Google Chrome:
    PS C:\> Get-KosigiBrowser -UserName ZXC123 -Browser Chrome -Datatype -All

    Get informations from MS Edge:
    PS C:\> Get-KosigiBrowser -UserName ZXC123 -Browser Edge -Datatype -All

    Data stored in:
    C:\Users\Public\KosigiBrowser-[UserName]
.NOTES
    Inspiration:
    https://www.sans.org/posters/windows-forensic-analysis/

    Stay Geeky!
#>
function Get-KosigiBrowser {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, ParameterSetName="UserName", Position = 0)]
        [String]$UserNameCMD,

        [Parameter(Position = 1)]
        [String[]]
        [ValidateSet('Chrome','Edge','All')]
        $Browser = 'All',

        [Parameter(Position = 2)]
        [String[]]
        [ValidateSet('History','Bookmarks','Cookies','Extensions','Sessions','All')]
        $DataType = 'All'
    )


    $Dest = "C:\Users\Public"
    New-Item -ItemType "directory" -Path "$Dest" -Name "KosigiBrowser-$UserNameCMD"
    $Destdir = "$Dest\KosigiBrowser-$UserNameCMD"


        function Get-ChromeHistory {
            $Path = "C:\Users\$UserNameCMD\AppData\Local\Google\Chrome\User Data\Default\History"
            Copy-Item $Path -Destination $Destdir\ChromeHistory
            $Path = "C:\Users\$UserNameCMD\AppData\Local\Google\Chrome\User Data\Default\DownloadMetadata"
            Copy-Item $Path -Destination $Destdir\ChromeDownload

        }

        function Get-EdgeHistory {
            $Path = "C:\Users\$UserNameCMD\AppData\Local\Microsoft\Edge\User Data\Default\History"
            Copy-Item $Path -Destination $Destdir\EdgeHistory

        }

        function Get-ChromeSession {
            $Path = "C:\Users\$UserNameCMD\AppData\Local\Google\Chrome\User Data\Default\Sessions"
            Copy-Item $Path -Destination $Destdir\ChromeSession -Recurse -Force
        }

        function Get-EdgeSession {
            $Path = "C:\Users\$UserNameCMD\AppData\Local\Microsoft\Edge\User Data\Default\Sessions"
            Copy-Item $Path -Destination $Destdir\EdgeSession -Recurse -Force
        }

        function Get-ChromeCookies {
            $Path = "C:\Users\$UserNameCMD\AppData\Local\Google\Chrome\User Data\Default\Cookies"
            Copy-Item $Path -Destination $Destdir\ChromeCookies
        }

        function Get-EdgeCookies {
            $Path = "C:\Users\$UserNameCMD\AppData\Local\Microsoft\Edge\User Data\Default\Cookies"
            Copy-Item $Path -Destination $Destdir\EdgeCookies
        }


        function Get-ChromeBookmarks {
            $Path = "C:\Users\$UserNameCMD\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
            Copy-Item $Path -Destination $Destdir\ChromeBookmarks
        }


        function Get-EdgeBookmarks {
            $Path = "C:\Users\$UserNameCMD\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks"
            Copy-Item $Path -Destination $Destdir\EdgeBookmarks
        }

        function Get-ChromeExtensions {
            $Path = "C:\Users\$UserNameCMD\AppData\Local\Google\Chrome\User Data\Default\Extensions"
            $extensions = Get-ChildItem $Path

            Foreach($ext in $extensions){

            Set-Location $Path\$ext -ErrorAction SilentlyContinue

            $folders = (Get-ChildItem).Name

            Foreach($folder in $folders){

            Set-Location $folder -ErrorAction SilentlyContinue

            $json = Get-Content manifest.json -Raw | ConvertFrom-Json

            $obj = New-Object System.Object

            $obj | Add-Member -MemberType NoteProperty -Name Name -Value $json.name
            $obj | Add-Member -MemberType NoteProperty -Name Version -Value $json.version

            $obj | Out-File "$Destdir\ChromeExtensions.txt" -Append
            }

            }

        }

        function Get-EdgeExtensions {
            $Path = "C:\Users\$UserNameCMD\AppData\Local\Microsoft\Edge\User Data\Default\Extensions"
            $extensions = Get-ChildItem $Path

            Foreach($ext in $extensions){

            Set-Location $Path\$ext -ErrorAction SilentlyContinue

            $folders = (Get-ChildItem).Name

            Foreach($folder in $folders){

            Set-Location $folder -ErrorAction SilentlyContinue

            $json = Get-Content manifest.json -Raw | ConvertFrom-Json

            $obj = New-Object System.Object

            $obj | Add-Member -MemberType NoteProperty -Name Name -Value $json.name
            $obj | Add-Member -MemberType NoteProperty -Name Version -Value $json.version

            $obj | Out-File "$Destdir\EdgeExtensions.txt" -Append

            }

            }
        }

    if(($Browser -Contains 'All') -or ($Browser -Contains 'Chrome')) {
        if (($DataType -Contains 'All') -or ($DataType -Contains 'History')) {
            Get-ChromeHistory
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Bookmarks')) {
            Get-ChromeBookmarks
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Cookies')) {
            Get-ChromeCookies
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Sessions')) {
            Get-ChromeSession
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Extensions')) {
            Get-ChromeExtensions
        }
    }

    if(($Browser -Contains 'All') -or ($Browser -Contains 'Edge')) {
        if (($DataType -Contains 'All') -or ($DataType -Contains 'History')) {
            Get-EdgeHistory
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Bookmarks')) {
            Get-EdgeBookmarks
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Cookies')) {
            Get-EdgeCookies
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Sessions')) {
            Get-EdgeSession
        }
        if (($DataType -Contains 'All') -or ($DataType -Contains 'Extensions')) {
            Get-EdgeExtensions
        }
    }
    Compress-Archive -Path $Destdir -DestinationPath $Destdir
    Write-Host "You can find the results in the $Destdir directory."
}
