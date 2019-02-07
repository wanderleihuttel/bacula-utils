<#
=================================================================================================
Hot Backup Hyper-V VM's
Name:  delete_backup_virtual_machine.ps1
Autor: Wanderlei Hüttel
Email: wanderlei.huttel@gmail.com
Versão 1.0 - 07/02/2019

Using cmdlets Windows Server Backup
https://docs.microsoft.com/en-us/powershell/module/windowsserverbackup/?view=win10-ps

=================================================================================================
#>
#========================  Not show warnings  ========================#
$WarningPreference = "SilentlyContinue"


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


#============  Remove the folder where the backups was saved ============#
if(Test-Path $BackupTarget){
   Remove-Item -Recurse -Force $BackupTarget | Out-Null
}

Exit 0