$packageName= 'VBoxVmService'
$url        = 'https://github.com/onlyfang/VBoxVmService/releases/download/6.0-Pumpkin/VBoxVmService-6.0-Pumpkin.exe'

$packageArgs = @{
  packageName   = $packageName
  fileType      = 'exe'
  url           = $url
  silentArgs    = "/VERYSILENT /NORESTART /NOCANCEL /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /SUPPRESSMSGBOXES"
  validExitCodes= @(0)
  softwareName  = 'VBoxVmService'
  checksum      = '24CC6DCF0C5F8C25FCA5181952E86C5525D83F981CAECE6C5DE1F3E1EC673546'
  checksumType  = 'sha256'
}

Install-ChocolateyPackage @packageArgs
