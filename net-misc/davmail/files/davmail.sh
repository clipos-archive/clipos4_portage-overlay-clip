#!/bin/sh
BASE=`dirname $0`
export LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
export CLASSPATH=/usr/local/share/swt-3.7/lib/swt.jar
for i in $BASE/lib/*; do export CLASSPATH=$CLASSPATH:$i; done
java -cp $BASE/davmail.jar:$CLASSPATH davmail.DavGateway $1
