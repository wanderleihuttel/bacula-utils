###############################################################
# Config Variables
$data = Get-Date -f "yyyyMMddhhmmss"
$file_extension = $args[0]
$root_folder = $args[1]
$file_list = "C:\Program Files\Bacula\scripts\$data.txt"

###############################################################
# Get all files by extension
$files = Get-ChildItem -Recurse -path $root_folder | Where-Object {$_.Extension -eq $file_extension}

###############################################################
# Test if the file_list exists and exclude
if (Test-Path $file_list){
  Remove-Item $file_list
}

###############################################################
# Create a new list 
foreach ($file in $files){
   $filename = $file.FullName
   Out-File  -filepath $file_list -inputobject "$filename" -Append
}

###############################################################
# Print the content of list
if (Test-Path $file_list){
  Get-Content $file_list
  Remove-Item $file_list
}
exit 0
