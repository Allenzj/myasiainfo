#!/bin/sh
ppid=`ps -fe|grep -w  config/${agent}|grep -v grep`
if [ ! -n "$ppid" ];then
	cd ../
	java -Dfile.encoding=UTF-8 -jar dacp-task-agent-2.0.0.jar config/${agent}/*.xml&
	echo "${agent} started successfully..."
else
 	echo "${agent} is running..."
fi
