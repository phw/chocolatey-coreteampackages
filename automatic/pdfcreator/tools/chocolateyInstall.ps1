﻿$checksum = 'c8eafc4d4380c1eaf43f49938ea16f39941a86ae62a25be25f16a3586f1b88fa'
$url = 'http://download.pdfforge.org/download/pdfcreator/3.0.1/PDFCreator-3_0_1-Setup.exe?file=PDFCreator-3_0_1-Setup.exe&download'

$installArgs = $('' +
  '/VERYSILENT /NORESTART ' +
  '/COMPONENTS="program,ghostscript,comsamples,' +
  'languages,languages\bosnian,languages\catalan,languages\catalan_valencia,' +
  'languages\chinese_simplified,languages\chinese_traditional,' +
  'languages\corsican,languages\croatian,languages\czech,languages\danish,' +
  'languages\dutch,languages\english,languages\estonian,languages\finnish,' +
  'languages\french,languages\galician,languages\german,languages\greek,' +
  'languages\hebrew,languages\hungarian,languages\italian,languages\irish,' +
  'languages\ligurian,languages\latvian,languages\lithuanian,' +
  'languages\norwegian_bokmal,languages\polish,languages\portuguese_br,' +
  'languages\romanian,languages\russian,languages\serbian_cyrillic,' +
  'languages\slovak,languages\slovenian,languages\spanish,' +
  'languages\swedish,languages\turkish,languages\valencian_avl"'
)

$packageArgs = @{
  packageName   = 'pdfcreator'
  unzipLocation = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
  fileType      = 'exe'
  url           = $url
  silentArgs    = $installArgs
  validExitCodes= @(0)
  softwareName  = 'pdfcreator*'
  checksum      = $checksum
  checksumType  = 'sha256'
}

# Make sure Print Spooler service is up and running
# this is required for both installing, and running pdfcreator
try {
  $serviceName = 'Spooler'
  $spoolerService = Get-WmiObject -Class Win32_Service -Property StartMode,State -Filter "Name='$serviceName'"
  if ($spoolerService -eq $null) { throw "Service $serviceName was not found" }
  Write-Host "Print Spooler service state: $($spoolerService.StartMode) / $($spoolerService.State)"
  if ($spoolerService.StartMode -ne 'Auto' -or $spoolerService.State -ne 'Running') {
    Set-Service $serviceName -StartupType Automatic -Status Running
    Write-Host "Print Spooler service new state: Auto / Running"
  }
} catch {
  Write-Warning "Unexpected error while checking Print Spooler service: $($_.Exception.Message)"
}

Install-ChocolateyPackage @packageArgs
