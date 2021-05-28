$absPath = $PSScriptRoot
$toolsPath = "$absPath\tools\"
$outputPath = "$(Split-Path -parent $absPath)\_output\"

Push-Location $PSScriptRoot

try {
  Write-Host
  Write-Host "`t[ synctex choco package update script ]"
  Write-Host

  $package_name = 'synctex'

  $base_url = 'https://www.tug.org/svn/texlive/trunk/Master/bin/win32/'

  $synctex_rev_file    = 'lastrev-synctex.txt'
  $synctex_binary_file = 'synctex.exe'

  $lib_rev_file        = 'lastrev-lib.txt'
  $lib_binary_file_re  = '(?<libfname>kpathsea\d+\.dll)'
  $lib_binary_file     = 'kpathsea___.dll'

  #-------------------------- FUNCTIONS -------------------------------------------------
  function GetLatestKnownRevision {
    param( [string]$filename )

    if ( -not ( Test-Path "$absPath\$filename" ) )
    {
        New-Item "$absPath\$filename" -Type file | Out-Null
        [IO.File]::WriteAllLines( "$absPath\$filename", "1`n" )
    }
    $lastrev  = (Get-Content "$absPath\$filename" -First 1).Trim()
    return [int]$lastrev
  }

  function UpdateLatestKnownRevision {
    param( [int]$rev, [string]$filename )

    if ( -not ( Test-Path "$absPath\$filename" ) )
    {
        New-Item "$absPath\$filename" -Type file | Out-Null
    }
    [IO.File]::WriteAllLines( "$absPath\$filename", "$rev`n" )
  }

  function GetWebPage {
    param( [string]$url )

    return [string]::Concat( $( & curl -s $url ) )
  }

  function GetLatestRevisionNumber {
    param( [string]$filename )

    $webpage = GetWebPage "$base_url${filename}?view=log"
    $m = Select-String -InputObject $webpage -Pattern '<\s*div\s*>\s*<\s*hr\s*/?>\s*<\s*a\s+name\s*=\s*"rev(\d+)"\s*>' -AllMatches
    $max = ($m.Matches | % { $_.Groups[1] } | % { [int]$_.Value } | measure -max).Maximum

    return [int]$max
  }

  function DownloadFile {
    param( [string]$filename, [int]$revision )

    curl -L -o "$toolsPath/$filename" "${base_url}${filename}?revision=${revision}&view=co"
  }
  #---------------------------------------------------------------------------

  $synctex_last_known_rev = GetLatestKnownRevision $synctex_rev_file
  Write-Host "Last known '$synctex_binary_file' revision is $synctex_last_known_rev"

  $lib_last_known_rev = 0
  # $lib_last_known_rev = GetLatestKnownRevision $lib_rev_file
  # Write-Host "Last known '$lib_binary_file' revision is $lib_last_known_rev"

  # $webpage = GetWebPage $base_url
  # if ( $webpage -match $lib_binary_file_re ) {
  #   $lib_binary_file = $Matches.libfname
  # } else {
  #   "Library binary file not found in the repo!"
  #   exit
  # }

  $synctex_lastrev = GetLatestRevisionNumber $synctex_binary_file
  $lib_lastrev = 0 # GetLatestRevisionNumber $lib_binary_file

  if ( ( $synctex_lastrev -gt $synctex_last_known_rev ) -or ( $lib_lastrev -gt $lib_last_known_rev ) ) {
    "Found '$synctex_binary_file' revision $synctex_lastrev"
    UpdateLatestKnownRevision $synctex_lastrev $synctex_rev_file
    "Found '$lib_binary_file' revision $lib_lastrev"
    UpdateLatestKnownRevision $lib_lastrev $lib_rev_file
  } else {
    "No new version... Exiting"
    exit
  }

  DownloadFile $synctex_binary_file $synctex_lastrev
  # DownloadFile $lib_binary_file $lib_lastrev

  $content = cat "$absPath\$package_name.nuspec.template" | % { $_ -replace "{{VERSION}}", "${synctex_lastrev}.${lib_lastrev}" }
  touch "$absPath\$package_name.nuspec"
  [IO.File]::WriteAllLines( "$absPath\$package_name.nuspec", $content )

  Push-Location $absPath
  & "choco" @("pack", "$absPath\$package_name.nuspec")
  Pop-Location

  rm "$absPath\$package_name.nuspec"

  if ( -not ( Test-Path $outputPath ) )
  {
      md $outputPath | Out-Null
  }

  mv "$absPath\$package_name*nupkg" $outputPath -Force

  Write-Host "Package could be found in $outputPath"
  Write-Host
}
finally {
  Pop-Location
}
