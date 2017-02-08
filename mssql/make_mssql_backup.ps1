<#
O Script abaixo contempla o Backup de 'N' Databases.  Testado nas versões 2008r2 e 2012r2 do Microsoft Sql Server
Necessário instalar os componentes abaixo: Pesquisar pela sua versão do SQL
Microsoft sql server 2008 r2 management objects
Microsoft Windows PowerShell Extensions for SQL Server 2008 R2
https://www.microsoft.com/en-us/download/details.aspx?id=16978
Não esquecer de desbloquear a execução de scripts utilizando Set-ExecutionPolicy unrestricted -force
Créditos: Victor França

#>
##Add-PSSnapin sqlservercmdletsnapin100
<#Variaveis:
$bancos > colocar o nome de cada Database que precisa backupear.  Colocar o nome de cada banco entre " " e separar por ,

$UserDb > Sugiro criar um usuário com permissão apenas de backupoperator em cada database pois a senha estará em um arquivo em Plain text

$PassDb > Senha do banco

$Sqlinstance > nome ou ip do servidor (caso seja uma instância nomeada, colocar assim:  SERVIDOR/INSTANCIA)

$DirBackup > Diretório local onde será armazenado o Dump de cada Banco (Ex 'c:\')

$timeout > defina um timeout para a query de backup (segundos)

#>
$databases=@("DatabaseName1","DatabaseName2","DatabaseName3")
$userDb='UserSql1'
$PassDb='PassSql*'
$Sqlinstance='Address/instance'
$DirBackup='c:\backup_mssql'
$timeout=7200

Remove-Item "$DirBackup\*.bak"

foreach($database in $databases){
   $date=get-date -Format dd_MM_yyyy_HH_mm_ss
   $FileBkp=$DirBackup+$database+'_'+$date+'.bak'
   Write-Host "Dump da base iniciada: database ..."
   Invoke-Sqlcmd -User $userDb -Password $PassDb -ServerInstance $Sqlinstance -Query "BACKUP DATABASE [$database] TO  DISK = '$FileBkp' WITH INIT" -timeout $timeout
}
