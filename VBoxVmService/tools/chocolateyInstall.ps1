$packageName= 'VBoxVmService'
$url        = 'https://sourceforge.net/projects/vboxvmservice/files/vboxvmservice/Versions%205.x/VBoxVmService-5.2-Jujube.exe/download'

$packageArgs = @{
  packageName   = $packageName
  fileType      = 'exe'
  url           = $url
  silentArgs    = "/VERYSILENT /NORESTART /NOCANCEL /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /SUPPRESSMSGBOXES"
  validExitCodes= @(0)
  softwareName  = 'VBoxVmService'
  checksum      = '3F19B7CEF57005194CBA6445FFCC0ED7E6A8B2E51DA547CA161598DB9858B22C'
  checksumType  = 'sha256'
}

Install-ChocolateyPackage @packageArgs
