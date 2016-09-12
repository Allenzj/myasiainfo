#!/bin/sh
ppid=`ps -fe|grep -w config/${agent}|grep -v grep`
if [ ! -n "$ppid" ];then
 echo "the dacp-task-agent config/${agent}/*.xml  is stopped....."
else
 pid=`ps -ef|grep config/${agent}|grep -v grep|awk '{print $2}'`
  for id in $pid
  do
  echo $id
   kill -9 $id
   done
   echo "${agent} killed successfully...."
fi
