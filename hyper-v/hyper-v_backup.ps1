<#
=================================================================================================
Hot Backup Hyper-V VM's
Autor: Wanderlei Hüttel
wanderlei@huttel.com.br
Versão 1.0 - 07/02/2018
=================================================================================================
#>

#============  Configuration  ============#
# Backup Target Folder
$backup_target="C:\backup_hyper-v"
#$backup_target="\\server\backup_folder"

# If using a local folder leave username and password empty
# Username of shared folder
#$username = "administrator"
$username = ""

# Password of shared folder
#$password = "type_your_password"
$password = ""
#============  Configuration  ============#

# Get all VM's name to backup
$vms = Get-VM | foreach {$_.name}
$vm_name = $vms -join ","
$vm_name = """$vm_name"""

# If isset an argument only backup one VM
if ($args.count -eq 1){
   $vm_name = $args[0]
   $vm_name = """$vm_name"""
}

$command = "C:\windows\System32\wbadmin.exe"
$Arg1 = "start"
$Arg2 = "backup"
$Arg3 = "-backuptarget:$backup_target"
$Arg4 = "-hyperv:$vm_name"
$Arg5 = "-vssFull"
$Arg6 = "-user $username"
$Arg7 = "-password $password"
$Arg8 = "-quiet"

if (-not($username -and $password)){
   $Arg6 = ""
   $Arg7 = ""
}
$Command = "$Exec $Arg1 $Arg2 $Arg3 $Arg4 $Arg5 $Arg6 $Arg7 $Arg8"

write-host $Command
Invoke-Expression $Command
Exit 0
