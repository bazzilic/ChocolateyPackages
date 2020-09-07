Uninstall-ChocolateyZipPackage `
    -PackageName "pyenv-win" `
    -ZipFileName "pyenv-win.zip"

Uninstall-ChocolateyEnvironmentVariable `
    -VariableName 'PYENV' `
    -VariableType 'User'

$path = [System.Environment]::GetEnvironmentVariable('PATH', 'User')

$path = ($path.Split(';') | Where-Object { $_ -notlike '*\.pyenv\pyenv-win\*' }) -join ';'

[System.Environment]::SetEnvironmentVariable(
    'PATH',
    $path,
    'User'
)
