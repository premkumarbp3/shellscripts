#!/bin/bash

cdate=$(date '+%Y%m%d_%H%M')
tomailid="Your MailID"
filename="resultfilename-${cdate}.tar.gz"
servername="$HOSTNAME"
backup_destination="/data"
logs_destination="/${backup_destination}/logs"
logfile="/${logs_destination}/mysqlbackup_log_${cdate}.txt"
db_list=(db1 db2 db3 db4)
s3destination="s3bucketname"

send_mail()
{
        if [ "$1" == "Success" ]
        then
                mail -s "Mysql Backup of $2 Completed at $servername" $tomailid<<EOF
                Hi Team,
                    Mysql backup at $servername server Completed for $2.

                Regards,
                Operations
EOF
        elif [ "$1" == "Failed" ]
        then
                mail -s "Mysql Backup of $2 Failed at $servername" $tomailid<<EOF
                Hi Team,
                Please check mysql backup at $servername server and fix the issue ASAP.
        
                Regards,
                Operations
EOF
        elif [ "$1" == "S3Success" ]
        then
                mail -s "Mysql Backup successfully Copied to S3" $tomailid<<EOF
                Hi Team,
                        Mysql backup file successfully Copied to S3 bucket.
                        Filename: $2

                Regards
                Operations
EOF
EOF
        else
                mail -s "Mysql Backup S3 Failed" $tomailid<<EOF
                Hi Team,
                        Cant Copy  file to S3 Please check ASAP.
                        FileName: $2

                Regards
                Operations
EOF
        fi
}

remove_old()
{
        find $backup_destination -type f -mtime +2 -exec rm -f {} \;
        find $logs_destination -name "mysqlbackup_log_*.txt" -type f -mtime +6 -exec rm -f {} \;
}
db_backup()
{
        echo "Mysqldump Started at $(date '+%Y%m%d-%T' )" 1>> $logfile 2>&1
        for i in ${db_list[@]}
        do
                echo "[ $i ] database dump Started at $(date '+%Y%m%d-%T' )" 1>> $logfile 2>&1
                mysqldump -u zzzzz -p'xxxxx' --routines --quick --skip-lock-tables --single-transaction $i | gzip > /${backup_destination}/${i}_${cdate}.sql.gz
                if [ $? -eq 0 ];then
                        echo "$cdate : $i backup successfully completed" 1>> $logfile 2>&1
                        remove_old
                        send_mail Success $i
                else
                        echo "$cdate : $i backup Failed" 1>> $logfile 2>&1
                        send_mail Failed $i
                fi
                echo "[ $i ] database dump Completed at $(date '+%Y%m%d-%T' )" 1>> $logfile 2>&1
        done
        echo "Mysqldump completed at $(date '+%Y%m%d-%T' )" 1>> $logfile 2>&1
        tar -zcvf /${backup_destination}/$filename -C /${backup_destination}/ db1_${cdate}.sql.gz db2_${cdate}.sql.gz db3_${cdate}.sql.gz db4_${cdate}.sql.gz
        s3cmd put /${backup_destination}/$filename s3://${s3destination}/
        if [ $? -eq 0 ]
        then
                echo "$cdate : Copying data to S3 Success" 1>> $logfile 2>&1
                send_mail S3Success $filename

        else
                echo "$cdate : Copying data to S3 Failed" 1>> $logfile 2>&1
                send_mail S3Failure $filename
        fi
}

process_check()
{
        if [ ! -z $(pidof mysqld) ]
        then
                db_backup
        else
                echo "process not running"
                exit 1
        fi
}

process_check
