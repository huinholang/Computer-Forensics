<#
.SYNOPSIS
    KosigiFile - Find the file.
    Author:
    Huinholang

.DESCRIPTION
    Get-KosigiFile is a Powershell script that searches for files by hash (MD5, SHA1, SHA256, SHA384 and SHA512). The script has variables such as:
    * Algorithm - mandatory parameter. You have to set the algorithm you are looking for.
    * Hash - mandatory parameter. You have to set the hash of the file you are looking for.
    * Path - no a mandatory parameter. This is  a variable to narrow down a file search.
    Errors are in the .txt file in: C:\Users\Public\KosigiFile-error.txt
.EXAMPLE
    1. Import module:
    Import-Module .\Get-KosigiFile.ps1

    Hash search:

    2a. Look for the hash file: SHA256:
    Get-KosigiFile -Algorithm SHA256 -Hash "BF6FBC8507916B7A37886F9E5B372B3BAB0FD8BC5175S5F7EABC79371BAC3BF8"
    2b. Look for the hash file and path:
    Get-KosigiFile -Algorithm SHA256 -Hash "BF6FBC8507916B7A37886F9E5B372B3BAB0FD8BC5175S5F7EABC79371BAC3BF8" -Path "C:\Path\to\file\"

    File search:

    3. Look for the file name:
    Get-KosigiFile -FileName "test.xlsx" -Path "C:\Path\to\file\"

    Directory search:

    4. Look for the directory name:
    Get-KosigiFile -DirectoryName "Example" -Path "C:\Path\to\file\"
.NOTES

    Stay Geeky!
#>

function Get-KosigiFile{

    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('MD5','SHA1','SHA256','SHA384','SHA512')]
        [String]$Algorithm,

        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]$Hash,

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,

        [Parameter(Position=3)]
        [ValidateNotNullOrEmpty()]
        [String]$FileName,

        [Parameter(Position=4)]
        [ValidateNotNullOrEmpty()]
        [String]$DirectoryName

    )

    function Get-Hash{
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $fullresults = Get-ChildItem -Path $Path -Recurse | ForEach-Object {Get-FileHash -Path $_.FullName -Algorithm $Algorithm} | Where-Object {$_.Hash -eq $Hash}
        Write-Output $fullresults
        $sw.Stop()

        Write-Host "`n"
        Write-Host "Finish. File search took:`n"
        $sw.Elapsed
    }

    function Get-HashFullPath{
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $hashfullpathresults = Get-ChildItem -Path "C:\" -Recurse | ForEach-Object {Get-FileHash -Path $_.FullName -Algorithm $Algorithm} | Where-Object {$_.Hash -eq $Hash}
        Write-Output $hashfullpathresults
        $sw.Stop()

        Write-Host "`n"
        Write-Host "Finish. File search took:`n"
        $sw.Elapsed
   }

    function Get-FileName{
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $filenameresults = Get-ChildItem -Path $Path -Recurse | Where-Object {$_.Name -eq $FileName} | Select-Object $_.FullName
        Write-Output $filenameresults
        $sw.Stop()

        Write-Host "`n"
        Write-Host "Finish. File search took:`n"
        $sw.Elapsed
    }


    function Get-FileNameFullPath{
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $filenamefullpathresults = Get-ChildItem -Path "C:\" -Recurse | Where-Object {$_.Name -eq $FileName} | Select-Object $_.FullName
        Write-Output $filenamefullpathresults
        $sw.Stop()

        Write-Host "`n"
        Write-Host "Finish. File search took:`n"
        $sw.Elapsed

    }

    function Get-Directory{
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $directoryresults = Get-ChildItem $Path -Recurse | Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match $DirectoryName} | Select-Object $_.FullName
        Write-Output $directoryresults
        $sw.Stop()

        Write-Host "`n"
        Write-Host "Finish. File search took:`n"
        $sw.Elapsed
    }

    function Get-DirectoryFullPath{
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $directoryfullresults = Get-ChildItem "C:\" -Recurse | Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match $DirectoryName} | Select-Object $_.FullName
        Write-Output $directoryfullresults
        $sw.Stop()

        Write-Host "`n"
        Write-Host "Finish. File search took:`n"
        $sw.Elapsed
    }

# Conditional hashfile search
    if (($Algorithm -Contains 'SHA256') -and $Path) {
        Get-Hash 2> C:\Users\Public\KosigiFile-error.txt
    }
    elseif (($Algorithm -Contains 'MD5') -and $Path) {
        Get-Hash 2> C:\Users\Public\KosigiFile-error.txt
        }
    elseif (($Algorithm -Contains 'SHA1') -and $Path) {
        Get-Hash 2> C:\Users\Public\KosigiFile-error.txt
        }
    elseif (($Algorithm -Contains 'SHA384') -and $Path) {
        Get-Hash 2> C:\Users\Public\KosigiFile-error.txt
        }
    elseif (($Algorithm -Contains 'SHA512') -and $Path) {
        Get-Hash 2> C:\Users\Public\KosigiFile-error.txt
        }
    elseif (($Algorithm -Contains 'SHA256') -and !$Path) {
        Get-HashFullPath 2> C:\Users\Public\KosigiFile-error.txt
        }
    elseif (($Algorithm -Contains 'MD5') -and !$Path) {
        Get-HashFullPath 2> C:\Users\Public\KosigiFile-error.txt
        }
    elseif (($Algorithm -Contains 'SHA1') -and !$Path) {
        Get-HashFullPath 2> C:\Users\Public\KosigiFile-error.txt
        }
    elseif (($Algorithm -Contains 'SHA384') -and !$Path) {
        Get-HashFullPath 2> C:\Users\Public\KosigiFile-error.txt
        }
    elseif (($Algorithm -Contains 'SHA512') -and !$Path) {
        Get-HashFullPath 2> C:\Users\Public\KosigiFile-error.txt
        }

# Conditional filename search
    if ($FileName -and $Path) {
        Get-FileName 2> C:\Users\Public\KosigiFile-error.txt
    }
    elseif ($FileName -and !$Path) {
        Get-FileNameFullPath 2> C:\Users\Public\KosigiFile-error.txt
    }

# Conditional directory search
    if ($DirectoryName -and $Path) {
        Get-Directory 2> C:\Users\Public\KosigiFile-error.txt
    }
    elseif ($DirectoryName -and !$Path) {
        Get-DirectoryFullPath 2> C:\Users\Public\KosigiFile-error.txt
    }
}
