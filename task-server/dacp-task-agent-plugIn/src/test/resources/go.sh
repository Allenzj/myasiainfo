#!/bin/sh
export LANG=zh_CN.utf8
st=$@
args=`echo ${st} | sed 's/-\|:\| //g'`
cd dacp-dp-executor-plugins-0.0.1-SNAPSHOT
java -Dfile.encoding=UTF-8 -jar dacp-dp-executor-plugins-0.0.1-SNAPSHOT.jar ${st}
ret=$?
echo $ret
if [ $ret != 0 ] ; then
        echo "run $proc run fails!"
        exit 1
else
        echo "run $proc run success!"
        exit 0
fi  