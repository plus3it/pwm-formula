# Gotta make SELinux happy...
if [[ $(getenforce) = "Enforcing" ]] || [[ $(getenforce) = "Permissive" ]]
then
    chcon -R --reference=/usr/share/tomcat/webapps \
        /usr/share/tomcat/webapps/ROOT.war
    if [[ $(getsebool httpd_can_network_relay | \
        cut -d ">" -f 2 | sed 's/[ ]*//g') = "off" ]]
    then
        logger "Enabling httpd-based proxying within SELinux"
        setsebool -P httpd_can_network_relay=1
    fi
fi