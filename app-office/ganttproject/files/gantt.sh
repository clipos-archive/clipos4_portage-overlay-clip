#!/bin/sh

create_config() {
	cat > "/home/user/.ganttproject" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<ganttproject-options>
	<looknfeel name="GTK+" class="com.sun.java.swing.plaf.gtk.GTKLookAndFeel"/>
</ganttproject-options>
EOF
}

update_config() {
	grep -q 'GTK+' "/home/user/.ganttproject" && return 0
	sed -i -e '/looknfeel/d' "/home/user/.ganttproject"
	sed -i -e 's:<ganttproject-options>:<ganttproject-options>\n<looknfeel name="GTK+" class="com.sun.java.swing.plaf.gtk.GTKLookAndFeel"/>:' \
		"/home/user/.ganttproject"
}

export JAVA_HOME="/usr/local/lib/java"
export LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
export JRE_HOME="${JAVA_HOME}"
GP_HOME=.

LOCAL_CLASSPATH=$GP_HOME/eclipsito.jar

CONFIGURATION_FILE=ganttproject-eclipsito-config.xml
BOOT_CLASS=org.bardsoftware.eclipsito.Boot
LOG_FILE=/tmp/.ganttproject.log

JAVA_COMMAND=/usr/local/bin/java

if [[ -e "/home/user/.ganttproject" ]]; then
	update_config
else
	create_config
fi

cd /usr/local/lib/ganttproject || exit 1
exec $JAVA_COMMAND -Xmx256m -classpath $CLASSPATH:$LOCAL_CLASSPATH $BOOT_CLASS $CONFIGURATION_FILE "$@" >$LOG_FILE 2>&1
