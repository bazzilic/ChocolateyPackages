$lastbuild   = (Get-Content 'lastbuild.txt' -First 1).Trim()
$downloadUri = "http://farmanager.com/files/"

$productIdx86 = ''
$productIdx64 = ''

$buildx86 = ''
$buildx64 = ''

$x86filename = ''
$x64filename = ''

Write-Host
Write-Host "`t== Far Manager choco package update script =="
Write-Host "Last known build is" $lastbuild
Write-Host

$webpage = (Invoke-WebRequest -URI "http://farmanager.com/download.php?l=en").content

# X86
if ($webpage -match 'href="files/(Far30b\d+\.x86\.\d{8}\.msi)"')
{
    $x86filename = $Matches[1]
    $x86filename -match 'Far30b(\d+)\.x86\.\d{8}\.msi' | Out-Null
    $buildx86 = $Matches[1]

    Write-Host "Found a link to a stable x86 build" $buildx86

    if ( [convert]::ToInt32($buildx86) -ge [convert]::ToInt32($lastbuild) )
    {
        $tempfilename = [System.IO.Path]::GetTempFileName()
        Invoke-WebRequest -URI $downloadUri$x86filename -OutFile $tempfilename
        $productIdx86 = & ".\msi-get.exe" $tempfilename
    }
    else
    {
        Write-Host "No new version. Exiting."
        Write-Host
        Exit
    }
}

#X64
if ($webpage -match 'href="files/(Far30b\d+\.x64\.\d{8}\.msi)"')
{
    $x64filename = $Matches[1]
    $x64filename -match 'Far30b(\d+)\.x64\.\d{8}\.msi' | Out-Null
    $buildx64 = $Matches[1]

    Write-Host "Found a link to a stable x64 build" $buildx64

    if ( $buildx64 -ne $buildx86)
    {
        Write-Host "x86 build" $buildx86 "and x64 build" $buildx64 "mismatch."
        Write-Host "Try again later"
        Write-Host
        Exit
    }

    if ( [convert]::ToInt32($buildx64) -ge [convert]::ToInt32($lastbuild) )
    {
        $tempfilename = [System.IO.Path]::GetTempFileName()
        Invoke-WebRequest -URI $downloadUri$x64filename -OutFile $tempfilename
        $productIdx64 = & ".\msi-get.exe" $tempfilename
    }
    else
    {
        Write-Host "No new version. Exiting."
        Write-Host
        Exit
    }
}

echo $buildx64 | Out-File 'lastbuild.txt' -Encoding utf8

Write-Host

Write-Host "ProductId for x86 MSI:" $productIdx86
Write-Host "ProductId for x64 MSI:" $productIdx64

Write-Host

cat 'chocolateyUninstall.ps1.template' | % { $_ -replace   "<<<ProductIDx86>>>" ,  $productIdx86 }             | % { $_ -replace   "<<<ProductIDx64>>>" ,  $productIdx64 }             | Out-File 'tools\chocolateyUninstall.ps1' -Encoding utf8
cat 'chocolateyInstall.ps1.template'   | % { $_ -replace "<<<X86DownloadLink>>>", "$downloadUri$x86filename" } | % { $_ -replace "<<<X64DownloadLink>>>", "$downloadUri$x64filename" } | Out-File 'tools\chocolateyInstall.ps1'   -Encoding utf8
cat 'Far.nuspec.template' | % { $_ -replace "<<<Build>>>", $buildx86 } | Out-File 'Far.nuspec' -Encoding utf8

& "chocolatey" @("pack", "far.nuspec")

mv "Far.3.0.$buildx64.nupkg" "..\output\"

Write-Host "Package could be found in '..\output\' folder"
Write-Host
