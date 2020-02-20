#!/bin/sh
while inotifywait -e modify -e create -e delete -o /var/log/inotify --format '%w%f-%e' /usr/share/tomcat/webapps/ROOT/WEB-INF/; do
    /usr/local/bin/pwmconfmgmt.sh
done
