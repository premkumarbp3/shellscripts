#!/bin/bash
cdate=$(date '+%Y%m%d')
output_location="/var/log/"

memmonit()
{
echo "-----$(date '+%F %T %Z')-----" >> $output_location/memory_monit_${cdate}.txt
ps aux --sort -rss >> $output_location/memory_monit_${cdate}.txt
echo -e "-------------------------------------\n"  >> $output_location/memory_monit_${cdate}.txt
}

main(){
	if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then
		echo "This script is already running with PID `pidof -x $(basename $0) -o %PPID`" >> $output_location/memory_monit_${cdate}.txt
		exit
	else
		memmonit
	fi
	
}

main
