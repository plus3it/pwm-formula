#!/bin/bash
sleep 2
sha1tmp=$(sha1sum /usr/share/tomcat/webapps/ROOT/WEB-INF/PwmConfiguration.xml)
echo "$sha1tmp" > /tmp/sha1conf
# shellcheck disable=SC2162,SC2039
IFS=' ' read -a myarray <<< "$sha1tmp"
# shellcheck disable=SC2039
echo "${myarray[0]}" > /tmp/PwmConfiguration.xml.sha1
sed 's/.*\///' /tmp/sha1conf >> /tmp/PwmConfiguration.xml.sha1
sed -i ':a;N;$!ba;s/\n/\ /g' /tmp/PwmConfiguration.xml.sha1
rm -rf /tmp/sha1conf
logger "created sha1file in tmp"
# shellcheck disable=SC1083,SC1036,SC1088
aws s3 cp /usr/share/tomcat/webapps/ROOT/WEB-INF/PwmConfiguration.xml s3://{{ salt.pillar.get('pwm:lookup:config_bucket') }}/PwmConfiguration.xml
logger "s3 put conf.xml file"
# shellcheck disable=SC1036,SC1083,SC1088
aws s3 cp /tmp/PwmConfiguration.xml.sha1 s3://{{ salt.pillar.get('pwm:lookup:config_bucket') }}/PwmConfiguration.xml.sha1 --acl public-read
logger "s3 put conffile sha1"
