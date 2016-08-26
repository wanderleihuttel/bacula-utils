##################################################################################
# Set full path for Firebird gbak.exe
Set-Alias -Name gbak -Value "C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe"

##################################################################################
# Config 
$startDateTime   = Get-Date -f "dd/MM/yyyy HH:mm:ss"  # Date/time when script starts
$rootFolder      = "C:\firebird"                      # Root folder of firebird database
$databaseFolder  = $rootFolder + "\" + "database"     # Database Folder
$backupFolder    = $rootFolder + "\" + "backup"       # Backup Folder
$fbDatabase      = "database.fdb"                     # Database file (.fdb)
$fbBackup        = "database.fbk"                     # Backup file (.fbk)
$fbLog           = "database.log"                     # Log file (.log)
$fbUser          = "sysdba"                           # Firebird user
$fbPassword      = "masterkey"                        # Firebird password

# Verify if firebird dump and firebird log already exists in backup folder and exclude them
$file1 = $backupFolder + "\" + $fbBackup;
$file2 = $backupFolder + "\" + $fbLog;
if( Test-Path $file1){
  Remove-Item $file1
}
if( Test-Path $file2){
  Remove-Item $file2
}	
	
##################################################################################
# Start firebird backup
write-host "Firebird dump database started in:  $startDateTime"
write-host "gbak -B $databaseFolder\$fbDatabase $backupFolder\$fbBackup -Y $backupFolder\$fbLog -user $fbUser -pass $fbPassword"
gbak -B $databaseFolder\$fbDatabase $backupFolder\$fbBackup -Y $backupFolder\$fbLog -user $fbUser -pass $fbPassword
$endDateTime   = Get-Date -f "dd/MM/yyyy HH:mm:ss"
write-host "Firebird dump database finished in: $endDateTime"
Exit 0
