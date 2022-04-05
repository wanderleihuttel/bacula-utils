#!/bin/bash
# Author:   Wanderlei Hüttel
# Email:    wanderlei.huttel@gmail.com
# Version:  2.0
# Date:     April 05, 2022

#=============================================================================================================
# Copy Bacula Volumes to Onedrive/Wasabi S3 Cloud and notify by telegram
#=============================================================================================================

#=============================================================================================================
# Global Variables
# Do not modify the variables below
g_retval=0    # global return check
g_count=0     # global count files transferred
g_message=""  # global message 

# Binaries
rclone=$(which rclone)
jq=$(which jq)
curl=$(which curl)

# Date Variables
starttime=$(date +%s)
dayofweek=$(date +%u)
dayofmonth=$(date +%-d)

# These ones you can modify
# Rclone Default Parameters
log_file_tmp="/var/log/bacula/rclone.tmp"
log_file="/var/log/bacula/rclone.log"
debug="--log-file $log_file_tmp --log-level INFO"
options="--stats=1000m --rc --rc-web-gui --rc-addr 0.0.0.0:5572 --rc-user admin --rc-pass admin --rc-web-gui-no-open-browser"

# Debug Mode | 0=disabled verbose mode | 1=enabled verbose mode
debug_verbose=0

# Telegram API (Send messages)
api_token="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
chat_id="YYYYYYYYY"


#=============================================================================================================
# JSON with rclone commands
json='[
{"name":"/etc/bacula","command":"sync","provider":"onedrive","bucket":"bacula-backup","source":"/etc/bacula","destination":"/etc/bacula","params":"--onedrive-no-versions --exclude=\"*.pid\" --exclude=\"*.state\" --exclude=\"*.conmsg\" --exclude=\"*.trace\""},
{"name":"Pools: Diária, Semanal e Mensal","command":"copyto","provider":"onedrive","bucket":"bacula-backup","source":"/backup/disco01","destination":"/StorageLocal1","params":"--onedrive-no-versions --include=\"Volume-Diario-*\" --include=\"Volume-Semanal-*\" --include=\"Volume-Mensal-*\""},
{"name":"Pool: VM","command":"copyto","provider":"onedrive","bucket":"bacula-backup","source":"/backup/disco02","destination":"/StorageLocal2","params":"--onedrive-no-versions --include=\"Volume-VM-*\""}
]'


#=============================================================================================================
# Creates a lockfile during script execution
# If any other script is running it aborts the script
script_name=$(basename "$0")
lockfile="/var/run/$script_name.pid"
if [[ -e "$lockfile" ]]; then
    pid=$(cat $lockfile)
    if [[ -e /proc/$pid ]]; then
        echo "$script_name: Process $pid is still running, exiting."
        exit 1
    else
        # Clean up previous lock file
        rm -f $lockfile
    fi
fi
trap "rm -f $lockfile; exit $?" INT TERM EXIT
# write $$ (PID) to the lock file
echo "$$" > $lockfile


#=============================================================================================================
# Function to show messages on debug and send to log file
function fn_show_message(){
    if (( $debug_verbose == 1 )); then
        echo -ne "$(date +"%Y/%m/%d %H:%M:%S ")$1\n"
    fi
    echo "$(date +"%Y/%m/%d %H:%M:%S ")$1" >> $log_file
}


#=============================================================================================================
# Function to read rclone log and extract data summary
function fn_rclone_sync(){
    if (( $debug_verbose == 1 )); then
        cat $1
    fi
    cat $1 >> $log_file
    g_retval=$(cat $1  | grep "There was nothing to transfer" | wc -l)
    fn_show_message "Transfers had ocurred (g_retval: $g_retval)"
    if (( $g_retval == 0 )); then
        log=$(cat $1  | grep "^Transferred:\|^Errors:\|^Checks:\|^Elapsed time:" | sed 's/(\s+|\t)(.*//g' | sed -r 's/.*:\s+//g' |sed '1 s/Transferred/Bytes/g' | tr '\n' '|')
        bytes=$(echo $log | cut -d'|' -f1 | cut -d'/' -f1 | sed 's/\s$//g')
        files=$(echo $log | cut -d'|' -f3 | cut -d'/' -f1 | sed 's/\s//g')
        elapsed=$(echo $log | cut -d'|' -f4 | sed 's/\s//g')
    
        fn_show_message "log: $log"
        fn_show_message "variables: bytes=$bytes|files=$files|elapsed=$elapsed"
        g_message="Tamanho=$bytes/nArquivos=$files/nDuração=$elapsed/n"
        g_count=$(expr $g_count + $files)
    else
        fn_show_message "There was nothing to transfer (g_retval: $g_retval)"
    fi
    cat $log_file_tmp >> "/tmp/log.txt"
    rm -f $log_file_tmp
}

#=============================================================================================================
# Message
header=">>>>> 💾 RCLONE BACKUP TO CLOUD 📤 <<<<</n"
message="$header/n"
message="${message}Rclone Started/n$(date -d @$starttime +'%d/%m/%Y %H:%M:%S')/n/n"
fn_show_message "##### Rclone Copy Bacula Backup to Cloud ##### - start"


#=============================================================================================================
# Loop over JSON
i=0
limit=$(echo $json | $jq .[].command -r | wc -l)
while (( $i < $limit )); do 

    # get value from json
    name=$(echo $json | $jq ".[$i].name" -r);
    command=$(echo $json | $jq ".[$i].command" -r);
    provider=$(echo $json | $jq ".[$i].provider" -r);
    bucket=$(echo $json | $jq ".[$i].bucket" -r);
    source=$(echo $json | $jq ".[$i].source" -r);
    destination=$(echo $json | $jq ".[$i].destination" -r);
    params=$(echo $json | $jq ".[$i].params" -r | sed 's/#/"/g');
    rclone_cmd="${rclone} ${command} ${source} ${provider}:${bucket}${destination} ${options} ${params} ${debug}"

    # Execute rclone command
    fn_show_message "Command: $rclone_cmd"
    fn_show_message "Uploading: $name"
    #${rclone} ${command} ${source} ${provider}:${bucket}${destination} ${options} ${params} ${debug}
    eval $rclone_cmd
    
    # Get information from log
    fn_rclone_sync $log_file_tmp
    fn_show_message "loop (g_retval: $g_retval)"
    if (( $g_retval == 0 )); then
        message="${message}${name}/n"
        message="${message}${g_message}/n"
    fi
    (( i++ ))
done


fn_show_message "g_count: $g_count"
if (( $g_count > 0 )); then
    message="${message}Total de arquivos enviados: $g_count/n/n"
fi

endtime=$(date +%s)
totaltime=$(expr $endtime - $starttime + 10800)


fn_show_message "Rclone copy start:        $(date -d @$starttime +%H:%M:%S)"
fn_show_message "Rclone copy finished:     $(date -d @$endtime   +%H:%M:%S)"
fn_show_message "Rclone copy elapsed time: $(date -d @$totaltime +%H:%M:%S)"
fn_show_message "##### Rclone Copy Bacula Backup to Cloud ##### - finished"


# Send Telegram Message
message="${message}Rclone Finished/n$(date -d @$endtime +'%d/%m/%Y %H:%M:%S')/n/n"
message="${message}Rclone Elapsed Time/n$(date -d @$totaltime +%H:%M:%S)/n/n"
message=$(echo ${message} | sed 's/\/n/%0A/g')
url="https://api.telegram.org/bot${api_token}/sendMessage?chat_id=${chat_id}&text=${message}"
$curl -s "$url" > /dev/null
