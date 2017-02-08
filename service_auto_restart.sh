#!/bin/bash
if [[ "`pidof -x $(basename $0) -o %PPID`" ]]; then
      echo "This script is already running with PID `pidof -x $(basename $0) -o %PPID`"
      exit
fi

server=$(echo $HOSTNAME)
ip_addr="10.0.1.22"
from_addr="operations@monit.net"
to_addr="opsguy@monit.net"
MAIL=$(which mail)

tomcat=$(ps aux | grep "tomcat1/temp org.apache.catalina.startup.Bootstrap" | grep -v grep | awk '{print $2}')
wowza=$(ps aux | grep "com.wowza.wms.bootstrap.Bootstrap" | grep -v grep | awk '{print $2}')
mongodb=$(pidof mongod)
mysqldb=$(pidof mysqld)
memcache=$(pidof memcached)
apache=$(pidof apache2 -s)

down_alert()
{
$MAIL -aFrom:$from_addr -s "$1 is down on $server!" $to_addr<<EOF
$1 is Down on $server_name Please check!

******Additional Information******
Service     : $1
Down Time   : $2
IP Address  : $ip_addr
Server Name : $server

Regards
Operations
EOF
}

recovery_alert()
{
$MAIL -aFrom:$from_addr -s "$1 is Recoverd on server!" $to_addr<<EOF
$1 is Recoverd on $server_name.

******Additional Information******
Service     : $1
Down Time   : $2
Up Time     : $3
IP Address  : $ip_addr
Server Name : $server

Regards
Operations
EOF
}

free_check()
{
totmem=$(free -m | grep Mem | awk '{print $2}')
freemem=$(free -m | grep "buffers/cache" | awk '{print $4}')
free_percen=$(echo "($freemem*100)/$totmem"|bc)
  if [ $free_percen -gt 15 ]
  then
    sudo service $1 start
  else
    sleep 2m
    free_check $1
  fi
}

ps_check()
{
for i in $tomcat:tomcat1 $memcache:memcached $apache:apache2 $mysqldb:mysql
do
  pid=$(echo $i | awk -F':' '{print $1}')
  process=$(echo $i | awk -F':' '{print $2}')
  dtime=$(date +%Y.%m.%d-%T)
  
  if [ "$pid" = "" ]
  then
    if [ ! -f /tmp/${process}-down.txt ]
    then
	touch /tmp/${process}-down.txt
	echo "$process down $dtime" > /tmp/${process}-down.txt
        down_alert $process $dtime
        free_check $process
    else
	down_alert $process $dtime
	free_check $process
    fi
  else
	if [ -f /tmp/${process}-down.txt ]
        then
	  uptime=$(date +%Y.%m.%d-%T)
	  odtime=$(awk '{print $3}' /tmp/${process}-down.txt)
	  recovery_alert $process $odtime $uptime
	  rm -rf /tmp/${process}-down.txt
	else
	  echo "Working Fine File Already Removed"
	fi
  fi
done
}
ps_check
