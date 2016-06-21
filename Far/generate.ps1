$absPath = Split-Path -parent $PSCommandPath
$toolsPath = "$absPath\tools\"
$outputPath = "$(Split-Path -parent $absPath)\_output\"

if ( -not ( Test-Path "$absPath\lastbuild.txt" ) )
{
    New-Item "$absPath\lastbuild.txt" -Type file | Out-Null
    [IO.File]::WriteAllLines( "$absPath\lastbuild.txt", "1`n" )
}

$lastbuild   = (Get-Content "$absPath\lastbuild.txt" -First 1).Trim()
$downloadUri = "http://farmanager.com/files/"

$productCodex86 = ''
$productCodex64 = ''

$buildx86 = ''
$buildx64 = ''

$x86filename = ''
$x64filename = ''

Write-Host
Write-Host "`t[ Far Manager choco package update script ]"
Write-Host
Write-Host "Last known build is" $lastbuild

$webpage = ( Invoke-WebRequest -URI "http://farmanager.com/download.php?l=en" ).content

# X86
if ( $webpage -match 'href="files/(Far30b\d+\.x86\.\d{8}\.msi)"' )
{
    $x86filename = $Matches[1]
    $x86filename -match 'Far30b(\d+)\.x86\.\d{8}\.msi' | Out-Null
    $buildx86 = $Matches[1]

    Write-Host "Found a link to a stable x86 build" $buildx86

    if ( [convert]::ToInt32($buildx86) -gt [convert]::ToInt32($lastbuild) )
    {
        $tempfilename = [System.IO.Path]::GetTempFileName()
        Invoke-WebRequest -URI $downloadUri$x86filename -OutFile $tempfilename
        $productCodex86 = & "$absPath\msi-get.exe" $tempfilename
    }
    else
    {
        Write-Host "No new version. Exiting."
        Write-Host
        Exit
    }
}

#X64
if ( $webpage -match 'href="files/(Far30b\d+\.x64\.\d{8}\.msi)"' )
{
    $x64filename = $Matches[1]
    $x64filename -match 'Far30b(\d+)\.x64\.\d{8}\.msi' | Out-Null
    $buildx64 = $Matches[1]

    Write-Host "Found a link to a stable x64 build" $buildx64

    if ( $buildx64 -ne $buildx86 )
    {
        Write-Host "x86 build" $buildx86 "and x64 build" $buildx64 "mismatch."
        Write-Host "Try again later"
        Write-Host
        Exit
    }

    if ( [convert]::ToInt32($buildx64) -gt [convert]::ToInt32($lastbuild) )
    {
        $tempfilename = [System.IO.Path]::GetTempFileName()
        Invoke-WebRequest -URI $downloadUri$x64filename -OutFile $tempfilename
        $productCodex64 = & "$absPath\msi-get.exe" $tempfilename
    }
    else
    {
        Write-Host "No new version. Exiting."
        Write-Host
        Exit
    }
}

[IO.File]::WriteAllLines( "$absPath\lastbuild.txt", $buildx64 ) # currently the only way to write UTF8 without BOM

Write-Host

Write-Host "ProductCode for x86 MSI:" $productCodex86
Write-Host "ProductCode for x64 MSI:" $productCodex64

Write-Host

if ( -not ( Test-Path $toolsPath ) )
{
    md $toolsPath | Out-Null
}

$content = ''

$content = cat "$absPath\chocolateyUninstall.ps1.template" | % { $_ -replace "<<<ProductCodex86>>>", $productCodex86 } | % { $_ -replace "<<<ProductCodex64>>>", $productCodex64 }
[IO.File]::WriteAllLines( "$absPath\tools\chocolateyUninstall.ps1", $content )

$content = cat "$absPath\chocolateyInstall.ps1.template" | % { $_ -replace "<<<X86DownloadLink>>>", "$downloadUri$x86filename" } | % { $_ -replace "<<<X64DownloadLink>>>", "$downloadUri$x64filename" }
[IO.File]::WriteAllLines( "$absPath\tools\chocolateyInstall.ps1", $content )

$content = cat "$absPath\Far.nuspec.template" | % { $_ -replace "<<<Build>>>", $buildx86 }
[IO.File]::WriteAllLines( "$absPath\Far.nuspec", $content )

Push-Location -Path $absPath
& "choco" @("pack", "$absPath\Far.nuspec")
Pop-Location

if ( -not ( Test-Path $outputPath ) )
{
    md $outputPath | Out-Null
}

mv "$absPath\Far.3.0.$buildx64.nupkg" $outputPath -Force

Write-Host "Package could be found in $outputPath"
Write-Host
