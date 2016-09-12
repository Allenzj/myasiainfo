#!/bin/sh
ppid=`ps -fe|grep "dacp-task-server-deploy-2.0.0.jar" |grep -v grep`
if [ ! -n "$ppid" ];then
 echo "the dacp-task-server-deploy-2.0.0.jar is stopped....."
else
 pid=`ps -ef|grep "dacp-task-server-deploy-2.0.0.jar" |grep -v grep|awk '{print $2}'`
  for id in $pid
  do
  echo $id
   kill -9 $id
   done
   echo "dacp-task-server-deploy-2.0.0.jar killed successfully...."
fi



