#!/bin/bash
CATALINA_HOME="$(ls -d $LIFERAY_HOME/tomcat*)"

PATH=$CATALINA_HOME/bin:$PATH

catalina.sh run