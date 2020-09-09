#!/bin/bash
file_ext=$(date "+%d_%b_%Y-%H-%M")
alert_mail="Youremail@example.com"
find /data/backup/ -mtime +1 -exec rm {} \;
PGPASSWORD="mydbpassword" pg_dump -U postgres -h localhost -d database | gzip > /data/backup/postgressql-bac-${file_ext}.gz
if [ $? -eq 0 ]
then
	echo "Success"
	aws s3 cp /data/backup/postgressql-bac-${file_ext}.gz s3://bucket-postgres-backup/ &>> backup.log
	if [ $? -eq 0 ]
	then
		echo "postgres backup Successfully copied to s3" | mail -s "POSTGRES Backup" $alert_mail
	else
		echo "postgres s3 backup failed" | mail -s "POSTGRES Backup" $alert_mail
	fi
else
	echo "postgres backup failed" | mail -s "POSTGRES Backup" $alert_mail
fi
