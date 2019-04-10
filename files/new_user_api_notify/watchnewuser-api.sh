#!/bin/sh
# Script that will grep a log file and run a php script when a specified pattern is encountered.
__ScriptName="watchnewuser-api.sh"

log()
{
    logger -i -t "${__ScriptName}" -s -- "$1" 2> /dev/console
    echo "$1"
}  # ----------  end of function log  ----------

#log "checking for new users"
newusers=$(grep -a "CREATE_USER" /usr/share/tomcat/webapps/ROOT/WEB-INF/logs/PWM.log)
echo "$newusers" > /usr/local/bin/current-newusers.log
chmod 600 /usr/local/bin/current-newusers.log

if   [ -e "/usr/local/bin/prior-newusers.log" ]
then
    echo "prior-newusers.log Exists" > /dev/null
else
    touch /usr/local/bin/prior-newusers.log
    echo "" > /usr/local/bin/prior-newusers.log
    chmod 600 /usr/local/bin/prior-newusers.log
fi

#compare prior newusers to current newusers
newuserentries=$(diff --suppress-common-lines -a /usr/local/bin/prior-newusers.log /usr/local/bin/current-newusers.log | grep -v "^---" | grep -v "^<")
if test "$newuserentries" != "" && test "$newusers" = ""
then
    log "should not see this log-diff of temp files isn't comparing correctly to actual log of new users"
elif test "$newuserentries" != ""
the    
    #count new entries and collect json key value pairs from log entry
    echo "$newuserentries" > /usr/local/bin/newuserentries
    diffcount=$(wc -l < /usr/local/bin/newuserentries)
    count=$((diffcount-1))
    while IFS="," read a b c foo; do echo $foo >> /usr/local/bin/onlyjson; done < /usr/local/bin/newuserentries
    cut -b 14- /usr/local/bin/onlyjson > /usr/local/bin/cleanjson
    #json keys differ in pwm18-targetID removed
    cat /usr/local/bin/cleanjson | jq '.perpetratorID, .timestamp, .sourceAddress' >> /usr/local/bin/prearray
    readarray -t myarray < /usr/local/bin/prearray
    #create html table snippets for email
    v=0
    for (( c=1; c<=$count; c++ ))
    do  
        cp /usr/local/bin/ostapi-newuserticket.php /usr/local/bin/ostapi-newuserticket$c.php
        __username__=${myarray[$v]}
        __time__=${myarray[$v+1]}
        __ip__=${myarray[$v+2]}
        sed -i "s/__username__/$__username__/g" /usr/local/bin/ostapi-newuserticket$c.php
        sed -i "s/__time__/$__time__/g" /usr/local/bin/ostapi-newuserticket$c.php
        sed -i "s/__ip__/$__ip__/g" /usr/local/bin/ostapi-newuserticket$c.php
        /usr/bin/php /usr/local/bin/ostapi-newuserticket$c.php
        v=$[v+3]
    done
    #cleanup for next run
    for (( c=1; c<=$count; c++ ))
    do
        shred -u /usr/local/bin/ostapi-newuserticket$c.php
    done
    shred -u /usr/local/bin/newuserentries
    shred -u /usr/local/bin/onlyjson
    shred -u /usr/local/bin/cleanjson
    shred -u /usr/local/bin/prearray
    echo "$newusers" > /usr/local/bin/prior-newusers.log
    chmod 600 /usr/local/bin/prior-newusers.log
    log "created tickets for list of new users via osticket api script"
else
    echo nothing > /dev/null
    #log "no new users"
fi