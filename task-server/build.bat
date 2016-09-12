call mvn -f dacp-task-parent/pom.xml clean install %* -Pprod -Dmaven.test.skip=true -Dfindbugs.skip=true
call mvn -f dacp-task-common/pom.xml clean install %* -Pprod -Dmaven.test.skip=true -Dfindbugs.skip=true
call mvn -f dacp-task-dbpro/pom.xml clean install %* -Pprod -Dmaven.test.skip=true -Dfindbugs.skip=true
call mvn -f dacp-task-context/pom.xml clean install %* -Pprod -Dmaven.test.skip=true -Dfindbugs.skip=true
call mvn -f dacp-task-server/pom.xml clean install %* -Pprod -Dmaven.test.skip=true -Dfindbugs.skip=true
call mvn -f dacp-task-server-deploy/pom.xml clean install %* -Pprod -Dmaven.test.skip=true -Dfindbugs.skip=true
call mvn -f dacp-task-agent/pom.xml clean install %* -Pprod -Dmaven.test.skip=true -Dfindbugs.skip=true

