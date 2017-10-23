$absPath = $PSScriptRoot
$toolsPath = "$absPath\tools\"
$outputPath = "$(Split-Path -parent $absPath)\_output\"

Write-Host
Write-Host "`t[ mysql-cli choco package update script ]"
Write-Host

Push-Location $absPath
& "choco" @("pack", "$absPath\mysql-cli.nuspec")
Pop-Location

if ( -not ( Test-Path $outputPath ) )
{
    md $outputPath | Out-Null
}

mv "$absPath\mysql-cli*nupkg" $outputPath -Force

Write-Host "Package could be found in $outputPath"
Write-Host
