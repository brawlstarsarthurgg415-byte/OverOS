# OverOS tablet inventory — read-only Windows PowerShell script
# Does not change boot settings, Secure Boot, partitions, or Windows files.
$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "=== OverOS | Inventario seguro do tablet ===" -ForegroundColor Cyan
Write-Host "Este relatorio apenas consulta informacoes. Nada sera alterado."
Write-Host ""

$cs = Get-CimInstance Win32_ComputerSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$os = Get-CimInstance Win32_OperatingSystem
$bios = Get-CimInstance Win32_BIOS
$board = Get-CimInstance Win32_BaseBoard
$video = Get-CimInstance Win32_VideoController
$disks = Get-CimInstance Win32_DiskDrive

Write-Host "[EQUIPAMENTO]" -ForegroundColor Yellow
"Fabricante: {0}" -f $cs.Manufacturer
"Modelo: {0}" -f $cs.Model
"Placa-base: {0} {1}" -f $board.Manufacturer, $board.Product
"BIOS/UEFI: {0}" -f $bios.SMBIOSBIOSVersion
"Processador: {0}" -f $cpu.Name
"Nucleos: {0} | Processadores logicos: {1}" -f $cpu.NumberOfCores, $cpu.NumberOfLogicalProcessors
"Arquitetura do Windows (0= x86, 9= x64, 12= ARM64): {0}" -f $os.OSArchitecture
"RAM instalada: {0:N2} GB" -f ($cs.TotalPhysicalMemory / 1GB)
"Versao do Windows: {0}" -f $os.Caption
"Build: {0}" -f $os.BuildNumber

Write-Host ""
Write-Host "[INICIALIZACAO SEGURA]" -ForegroundColor Yellow
try {
  $sb = Confirm-SecureBootUEFI
  "Secure Boot ativo: {0}" -f $sb
} catch {
  "Secure Boot: nao foi possivel consultar por este modo de inicializacao/permissao."
}
try {
  "Modo de firmware: {0}" -f (Get-ComputerInfo -Property BiosFirmwareType).BiosFirmwareType
} catch {
  "Modo de firmware: consulte msinfo32 (Modo da BIOS)."
}

Write-Host ""
Write-Host "[VIDEO]" -ForegroundColor Yellow
$video | ForEach-Object {
  "Adaptador: {0} | Driver: {1} | Resolucao atual: {2}x{3}" -f $_.Name, $_.DriverVersion, $_.CurrentHorizontalResolution, $_.CurrentVerticalResolution
}

Write-Host ""
Write-Host "[ARMAZENAMENTO — somente identificacao]" -ForegroundColor Yellow
$disks | ForEach-Object {
  "Disco: {0} | Modelo: {1} | Tamanho: {2:N1} GB | Interface: {3}" -f $_.DeviceID, $_.Model, ($_.Size / 1GB), $_.InterfaceType
}

Write-Host ""
Write-Host "[FIM] Nenhuma configuracao foi modificada." -ForegroundColor Green
