$absPath = Split-Path -parent $PSCommandPath
$toolsPath = "$absPath\tools\"
$outputPath = "$(Split-Path -parent $absPath)\_output\"

$downloadUri = "ftp://ftp.vim.org/pub/vim/pc/vim"

$version = ''
$build   = ''

$rtChecksum  = ''
$w32Checksum = ''

$ZipFileRT  = ''
$ZipFileEXE = ''

Write-Host
Write-Host "`t[ vim-console choco package update script ]"
Write-Host

$webpage = ( Invoke-WebRequest -URI "http://www.vim.org/download.php" ).content

$webpage -match 'vim(\d+)-(\d+)rt.zip' | Out-Null
$version = $Matches[1]
$build   = $Matches[2]
$versionPrint = $version.Insert(1,'.') + '.' + $build

$DLrt  = $downloadUri + $version + '-' + $build + 'rt.zip'
$DLexe = $downloadUri + $version + '-' + $build + 'w32.zip'

if ( $webpage -match "href=`"$DLrt`"" )
{
    Write-Host "Found a link to runtime files $version-$build"

    $tempfilename = [System.IO.Path]::GetTempFileName()
    Invoke-WebRequest -URI $DLrt -OutFile $tempfilename
    $rtChecksum = & checksum -t=sha256 $tempfilename
    $ZipFileRT = ([System.Uri]$DLrt).Segments[-1]
}

if ( $webpage -match "href=`"$DLexe`"" )
{
    Write-Host "Found a link to console executable $version-$build"

    $tempfilename = [System.IO.Path]::GetTempFileName()
    Invoke-WebRequest -URI $DLexe -OutFile $tempfilename
    $w32Checksum = & checksum -t=sha256 $tempfilename
    $ZipFileEXE = ([System.Uri]$DLexe).Segments[-1]
}

Write-Host "SHA256 checksum for RT ZIP  : $rtChecksum"
Write-Host "SHA256 checksum for EXE ZIP : $w32Checksum"

Write-Host

if ( -not ( Test-Path $toolsPath ) )
{
    md $toolsPath | Out-Null
}

$content = ''

$content = cat "$absPath\chocolateyInstall.ps1.template"   | `
    % { $_ -replace "<<<DLrt>>>", $DLrt }                  | `
    % { $_ -replace "<<<DLw32>>>", $DLexe }                | `
    % { $_ -replace "<<<rtChecksum>>>", $rtChecksum }      | `
    % { $_ -replace "<<<w32Checksum>>>", $w32Checksum }    | `
    % { $_ -replace "<<<Version>>>", $version }
[IO.File]::WriteAllLines( "$absPath\tools\chocolateyInstall.ps1", $content )

$content = cat "$absPath\chocolateyUninstall.ps1.template" |`
    % { $_ -replace "<<<ZipFileRT>", $ZipFileRT }          | `
    % { $_ -replace "<<<ZipFileEXE>>>", $ZipFileEXE }
[IO.File]::WriteAllLines( "$absPath\tools\chocolateyUninstall.ps1", $content )

$content = cat "$absPath\vim-console.nuspec.template"      | `
    % { $_ -replace "<<<Version>>>", $versionPrint }
[IO.File]::WriteAllLines( "$absPath\vim-console.nuspec", $content )

Push-Location -Path $absPath
& "choco" @("pack", "$absPath\vim-console.nuspec")
Pop-Location

if ( -not ( Test-Path $outputPath ) )
{
    md $outputPath | Out-Null
}

mv "$absPath\vim-console.$versionPrint.nupkg" $outputPath -Force

Write-Host "Package could be found in $outputPath"
Write-Host
