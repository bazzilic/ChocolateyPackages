$absPath = Split-Path -parent $PSCommandPath
$toolsPath = "$absPath\tools\"
$outputPath = "$(Split-Path -parent $absPath)\_output\"

if ( -not ( Test-Path "$absPath\lastbuild.txt" ) )
{
    New-Item "$absPath\lastbuild.txt" -Type file | Out-Null
    [IO.File]::WriteAllLines( "$absPath\lastbuild.txt", "fff`n" )
}

$folder = "$absPath\pyenv-win\"
if ( -not ( Test-Path $folder ) )
{
    git clone https://github.com/pyenv-win/pyenv-win.git
}

Push-Location $folder
git pull
$version = $(Get-Content '.\.version').Trim()
Pop-Location

$lastbuild = (Get-Content "$absPath\lastbuild.txt").Trim()

if ($version -eq $lastbuild)
{
    "No new version, exiting!"
    exit
}

cp "$folder\.version" "$abspath\lastbuild.txt"

$archive = "$abspath/tools/pyenv-win.zip"
Compress-Archive -Path "$folder/*" -DestinationPath $archive -CompressionLevel Optimal -Force
$checksum = & checksum -t=sha256 $archive

$content = Get-Content "$absPath\chocolateyInstall.ps1.template" | ForEach-Object { $_ -replace "<<<Sha256Checksum>>>", $checksum }
[IO.File]::WriteAllLines( "$absPath\tools\chocolateyInstall.ps1", $content )

$content = Get-Content "$absPath\pyenv-win.nuspec.template" | ForEach-Object { $_ -replace "<<<version>>>", $version }
[IO.File]::WriteAllLines( "$absPath\pyenv-win.nuspec", $content )

Push-Location -Path $absPath
& "choco" @("pack", "$absPath\pyenv-win.nuspec")
Pop-Location

if ( -not ( Test-Path $outputPath ) )
{
    mkdir $outputPath | Out-Null
}

Move-Item "$absPath\pyenv-win.$version.nupkg" $outputPath -Force

Write-Host "Package could be found in $outputPath"
Write-Host
