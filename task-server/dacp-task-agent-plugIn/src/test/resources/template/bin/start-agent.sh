#!/bin/sh
ppid=`ps -fe|grep -w  config/${agent}|grep -v grep`
if [ ! -n "$ppid" ];then
  cd ../
  java -Dfile.encoding=UTF-8 -jar dacp-task-agent-1.0.0.jar config/${agent}/*.xml&
  echo "dacp-task-agent config/${agent} started successfully..."
else
 echo "the dacp-task-agent config/${agent} is running..."
fi
