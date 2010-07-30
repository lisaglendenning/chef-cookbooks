#!/bin/sh

HUDSON_WAR=$HUDSON_HOME/hudson.war
HUDSON_LOG=$HUDSON_HOME/hudson.log
JAVA=$JAVA_HOME/bin/java
nohup nice $JAVA -jar $HUDSON_WAR > $HUDSON_LOG 2>&1
