$packageName= 'VBoxVmService'
$url        = 'https://github.com/onlyfang/VBoxVmService/releases/download/6.1-Kiwi/VBoxVmService-6.1-Kiwi.exe'

$packageArgs = @{
  packageName   = $packageName
  fileType      = 'exe'
  url           = $url
  silentArgs    = "/VERYSILENT /NORESTART /NOCANCEL /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /SUPPRESSMSGBOXES"
  validExitCodes= @(0)
  softwareName  = 'VBoxVmService'
  checksum      = 'EF181054002A4F11B07FE640F0DA572534C5D2B6C91896F4F688965B4BB0C0D9'
  checksumType  = 'sha256'
}

Install-ChocolateyPackage @packageArgs
