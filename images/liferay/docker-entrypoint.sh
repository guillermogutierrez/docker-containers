#!/bin/bash
CATALINA_HOME="$(ls -d $LIFERAY_HOME/tomcat*)"

PATH=$CATALINA_HOME/bin:$PATH

cp $LIFERAY_HOME/deploy_perm/* $LIFERAY_HOME/deploy

until nc -z -v -w30 'mysql' 3306
do
  echo "Waiting for database connection...5"
  # wait for 5 seconds before check again
  sleep 5
done

catalina.sh run