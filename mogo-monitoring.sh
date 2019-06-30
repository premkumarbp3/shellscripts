#!/bin/bash
main() {
    mo_insert=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o insert | awk -F"*" '{print $2}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name insert --unit Count --value "$mo_insert"

    mo_query=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o query | awk -F"*" '{print $2}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name query --unit Count --value "$mo_query"

    mo_update=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o update | awk -F"*" '{print $2}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name update --unit Count --value "$mo_update"

    mo_delete=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o delete | awk -F"*" '{print $2}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name delete --unit Count --value "$mo_delete"

    mo_getmore=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o getmore | awk '{print $1}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name getmore --unit Count --value "$mo_getmore"

    mo_conn=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o conn | awk '{print $1}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name conn --unit Count --value "$mo_conn"

    mo_command=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o command | awk -F'|' '{print $1}' | awk '{print $1}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name 'command' --unit Count --value "$mo_command"

    mo_res=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o res | awk -F'M' '{print $1}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name res --unit Megabytes --value "$mo_res"

    client_read_queue=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o qrw | awk -F'|' '{print $1}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name qr --unit Count --value "$client_read_queue"

    client_write_queue=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o qrw | awk -F'|' '{print $2}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name qw --unit Count --value "$client_read_queue"

    active_read_operations=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o arw | awk -F'|' '{print $1}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name ar --unit Count --value "$active_read_operations"

    active_write_operations=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 --noheaders -o arw | awk -F'|' '{print $2}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name aw --unit Count --value "$active_write_operations"

    mo_oplog_timediff=$(mongo -u $Mongo_User -p $Mongo_Password --eval "printjson(db.getReplicationInfo().timeDiff)"  | tail -n 1)
   aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name oplog_timediff --unit Seconds --value "$mo_oplog_timediff"

    #mo_dur_commits=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().dur.commits' | tail -n 1)
    #aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name dur_commits --unit Count --value "$mo_dur_commits"

#    mo_dur_jdMB=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().dur.journaledMB' | tail -n 1)
#    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name dur_jdMB --unit Megabytes, --value "$mo_dur_jdMB"

    read_ticket_use=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().wiredTiger.concurrentTransactions.read.out' | tail -n 1)
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name read_ticket_use --unit Count --value "$read_ticket_use"

    write_ticket_use=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().wiredTiger.concurrentTransactions.write.out' | tail -n 1)
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name write_ticket_use --unit Count --value "$write_ticket_use"

    avail_read_ticket_remaining=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().wiredTiger.concurrentTransactions.read.available' | tail -n 1)
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name avail_read_ticket_remaining --unit Count --value "$avail_read_ticket_remaining"

    avail_write_ticket_remaining=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().wiredTiger.concurrentTransactions.write.available' | tail -n 1)
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name avail_write_ticket_remaining --unit Count --value "$avail_write_ticket_remaining"

    no_cursors_opened=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().metrics.cursor.open.total' | tail -n 1 | awk -F'[()]' '{print $2}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name no_cursors_opened --unit Count --value "$no_cursors_opened"
    no_cursors_timedout=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().metrics.cursor.timedOut' | tail -n 1 | awk -F'[()]' '{print $2}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name no_cursors_timedout --unit Count --value "$no_cursors_timedout"
    no_cursors_timeout_dis=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().metrics.cursor.open.noTimeout' | tail -n 1 | awk -F'[()]' '{print $2}')
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name no_cursors_timeout_dis --unit Count --value "$no_cursors_timeout_dis"
    no_connected_clients=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().connections.current' | tail -n 1)
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name no_connected_clients --unit Count --value "$no_connected_clients"
    no_available_connections=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().connections.available' | tail -n 1) 
    aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$INSTANCE_ID" --metric-name no_available_connections --unit Count --value "$no_available_connections" 
}
repl_monit() {
  repl_enab=$(mongostat -u $Mongo_User -p $Mongo_Password --authenticationDatabase admin -n 1 | grep -o repl)
  if [ ! -z $repl_enab ]
  then
      primary_host=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().repl.primary' | tail -n 1)
      current_host=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.serverStatus().repl.me' | tail -n 1)
      if [ $primary_host = $current_host ]
      then
        slave_list=($(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.printSlaveReplicationInfo()' | grep "source"| awk '{print $2}'))
        for i in "${slave_list[@]}"
        do
          oplag=$(mongo -u $Mongo_User -p $Mongo_Password --eval 'db.printSlaveReplicationInfo()' | grep -A 2 "$i" | paste -d' ' - - -  | awk '{print $11}')
          aws cloudwatch put-metric-data --region "$REGION" --namespace MongoServices --dimensions MongoDB="$i" --metric-name oplag --unit Seconds --value "$oplag"
        done
      fi
  fi
}
REGION=$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone | sed s/.$//)
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
Mongo_User="admin"
Mongo_Password="rs1admin"
mongo -u $Mongo_User -p $Mongo_Password --eval  "printjson(db.serverStatus())" > /dev/null 2>&1
MONGO_PID=$(pidof mongod)
AWSCLI=$(which aws)
if [[ -z $AWSCLI ]]
then
    echo "awscli not found"
    exit 1
fi
if [[ ! -z $MONGO_PID ]]
then
    main
    repl_monit
fi
