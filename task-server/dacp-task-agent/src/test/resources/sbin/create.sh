#!/bin/bash

if [ $# -ne 4 ];then

echo "input program args error... exit! "

exit -1

fi

agent=$1
ip=$2
username=$3
password=$4

agent_f="../config/${1}"
echo $agent_f

#create agent directory

if [ ! -d "${agent_f}" ];then
  mkdir -pv ${agent_f}
fi
if [ ! -d "../bin" ];then
  mkdir ../bin
fi

#copy and create file from template directory

cp ../template/config/applicationContext.xml ${agent_f}/applicationContext.xml
sed -i "s/\${agent}/${agent}/g" ${agent_f}/applicationContext.xml
sed -i "s/\${ip_address}/${ip}/g" ${agent_f}/applicationContext.xml
sed -i "s/\${username}/${username}/g" ${agent_f}/applicationContext.xml
sed -i "s/\${password}/${password}/g" ${agent_f}/applicationContext.xml

cp ../template/config/agentconfig.properties ${agent_f}/agentconfig.properties
sed -i "s/\${agent}/${agent}/g" ${agent_f}/agentconfig.properties

cp ../template/bin/start-agent.sh ../bin/start-${agent}.sh

sed -i "s/\${agent}/${agent}/g"   ../bin/start-${agent}.sh

chmod +x ../bin/start-${agent}.sh

cp ../template/bin/stop-agent.sh  ../bin/stop-${agent}.sh

sed -i "s/\${agent}/${agent}/g"   ../bin/stop-${agent}.sh

chmod +x ../bin/stop-${agent}.sh