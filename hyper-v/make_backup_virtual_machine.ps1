<#
=================================================================================================
Hot Backup Hyper-V VM's
Name:  make_backup_virtual_machine.ps1
Autor: Wanderlei Hüttel
Email: wanderlei.huttel@gmail.com
Versão 1.0 - 07/02/2019

Using cmdlets Windows Server Backup
https://docs.microsoft.com/en-us/powershell/module/windowsserverbackup/?view=win10-ps

=================================================================================================
#>
#========================  Not show warnings  ========================#
$WarningPreference = "SilentlyContinue"


#========================  Function to return difference between dates  ========================#
Function DateDiff-DateTime() {
    Param ($DateTimeStart, $DateTimeEnd)
    $ts = New-TimeSpan –Start $DateTimeStart –End $DateTimeEnd
    $TotalHora = "{0:hh}:{0:mm}:{0:ss}" -f $ts #.Negate() #Caso fique negativo
    return $TotalHora
}


#========================  Check argument 1 (VM_NAME) is passed ========================#
if ($args.count -eq 0){
   Write-Host "Parameter 1 is required! (VM_NAME)"
   Exit 1 
}
else{
   $vm_name = $args[0]
}


#========================  Configuration  ========================#
# Backup Target is a localhost shared folder because Windows Backup
# not accept copy to a single folder
$BackupTarget = "\\localhost\D$\backup_hyper-v\$vm_name"


#========================  Start script  ========================#
$StartTime  = Get-Date
Write-Host "========== Hyper-V - Windows Backup Virtual Machines =========="
Write-Host "Backup VM ($vm_name) started:   " $StartTime.toString("dd/MM/yyyy HH:mm:ss")


#============  Check if the folder with VM_NAME exists. If not exist, it created ============#
if(!(Test-Path $BackupTarget)){
   New-Item -ItemType Directory -Path $BackupTarget | Out-Null
}


#========================  Set policy  ========================#
$policy = New-WBPolicy


#========================  Set VSS option  ========================#
Set-WBVssBackupOption -Policy $policy -VssFullBackup


#========================  Set Backup Location  ========================#
$BackupLocation = New-WBBackupTarget -NetworkPath $BackupTarget
Add-WBBackupTarget -Policy $policy -Target $BackupLocation -Force | Out-Null


#========================  Set VM to Backup  ========================#
$VirtualMachine = Get-WBVirtualMachine | where {$_.VMName -like $vm_name}
Add-WBVirtualMachine -Policy $policy -VirtualMachine $VirtualMachine | Out-Null


#========================  Start VM Backup ========================#
Start-WBBackup -Policy $policy -AllowDeleteOldBackups | Out-Null


#========================  End Backup ========================#
$EndTime = Get-Date
Write-Host "Backup VM ($vm_name) finished:  " $EndTime.toString("dd/MM/yyyy HH:mm:ss")
Write-Host "Elapsed time:                 " (DateDiff-DateTime $StartTime $EndTime)
Write-Host "========== Hyper-V - Windows Backup Virtual Machines =========="

Exit 0


