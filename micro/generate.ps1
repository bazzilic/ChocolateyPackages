$absPath = Split-Path -parent $PSCommandPath
$toolsPath = "$absPath\tools\"
$outputPath = "$(Split-Path -parent $absPath)\_output\"

$downloadUri = "https://github.com/zyedidia/micro/releases/download/v"

$version = ''

$x86Checksum = ''
$x64Checksum = ''

$ZipFileNamex86 = ''
$ZipFileNamex64 = ''

Write-Host
Write-Host "`t[ micro choco package update script ]"
Write-Host

$webpage = ( Invoke-WebRequest -URI "https://github.com/zyedidia/micro/releases/latest" ).content

$webpage -match 'v(\d+\.\d+\.\d+)' | Out-Null
$version = $Matches[1]

$x86DownloadLink = '/zyedidia/micro/releases/download/v' + $version + '/micro-' + $version + '-win32.zip'
$x64DownloadLink = '/zyedidia/micro/releases/download/v' + $version + '/micro-' + $version + '-win64.zip'

# X86
if ( $webpage -match "href=`"$x86DownloadLink`"" )
{
    Write-Host "Found a link to a stable x86 build" $version
    $x86DownloadLink = 'https://github.com' + $x86DownloadLink

    $tempfilename = [System.IO.Path]::GetTempFileName()
    Invoke-WebRequest -URI $x86DownloadLink -OutFile $tempfilename
    $x86Checksum = & checksum -t=sha256 $tempfilename
    $ZipFileNamex86 = ([System.Uri]$x86DownloadLink).Segments[-1]
}

#X64
if ( $webpage -match "`href=`"$x64DownloadLink`"" )
{
    Write-Host "Found a link to a stable x64 build" $version
    $x64DownloadLink = 'https://github.com' + $x64DownloadLink

    $tempfilename = [System.IO.Path]::GetTempFileName()
    Invoke-WebRequest -URI $x64DownloadLink -OutFile $tempfilename
    $x64Checksum = & checksum -t=sha256 $tempfilename
    $ZipFileNamex64 = ([System.Uri]$x64DownloadLink).Segments[-1]
}

Write-Host "SHA256 checksum for x86 ZIP:" $x86Checksum
Write-Host "SHA256 checksum for x64 ZIP:" $x64Checksum

Write-Host

if ( -not ( Test-Path $toolsPath ) )
{
    md $toolsPath | Out-Null
}

$content = ''

$content = cat "$absPath\chocolateyInstall.ps1.template" | % { $_ -replace "<<<X86DownloadLink>>>", $x86DownloadLink } | % { $_ -replace "<<<X64DownloadLink>>>", $x64DownloadLink } | % { $_ -replace "<<<Sha256ChecksumX86>>>", $x86Checksum } | % { $_ -replace "<<<Sha256ChecksumX64>>>", $x64Checksum }
[IO.File]::WriteAllLines( "$absPath\tools\chocolateyInstall.ps1", $content )

$content = cat "$absPath\chocolateyUninstall.ps1.template" | % { $_ -replace "<<<ZipFileNamex86>>>", $ZipFileNamex86 } | % { $_ -replace "<<<ZipFileNamex64>>>", $ZipFileNamex64 }
[IO.File]::WriteAllLines( "$absPath\tools\chocolateyUninstall.ps1", $content )

$content = cat "$absPath\micro.nuspec.template" | % { $_ -replace "<<<Version>>>", $version }
[IO.File]::WriteAllLines( "$absPath\micro.nuspec", $content )

Push-Location -Path $absPath
& "choco" @("pack", "$absPath\micro.nuspec")
Pop-Location

if ( -not ( Test-Path $outputPath ) )
{
    md $outputPath | Out-Null
}

mv "$absPath\micro.$version.nupkg" $outputPath -Force

Write-Host "Package could be found in $outputPath"
Write-Host
