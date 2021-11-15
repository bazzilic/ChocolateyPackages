$packageName= 'VBoxVmService'
$url        = 'https://github.com/onlyfang/VBoxVmService/releases/download/6.1-Kiwi/VBoxVmService-6.1-Kiwi.exe'

$packageArgs = @{
  packageName   = $packageName
  fileType      = 'exe'
  url           = $url
  silentArgs    = "/VERYSILENT /NORESTART /NOCANCEL /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /SUPPRESSMSGBOXES"
  validExitCodes= @(0)
  softwareName  = 'VBoxVmService'
  checksum      = '6E1F8272E693E0974176873952242D36252F537DCEA024596BAD7D68AE51275F'
  checksumType  = 'sha256'
}

Install-ChocolateyPackage @packageArgs
