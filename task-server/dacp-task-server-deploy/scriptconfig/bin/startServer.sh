#!/bin/sh
ppid=`ps -fe|grep "dacp-task-server-deploy-2.0.0.jar" |grep -v grep`
if [ ! -n "$ppid" ];then
	cd ../
	java -Dfile.encoding=UTF-8 -jar dacp-task-server-deploy-2.0.0.jar &
	echo "dacp-task-server-deploy-2.0.0.jar started successfully......"
else
 	echo "dacp-task-server-deploy-2.0.0.jar is running....."
fi



