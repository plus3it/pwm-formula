get_pwm_config:
  file.managed:
    - name: /usr/share/tomcat/webapps/ROOT/WEB-INF/PwmConfiguration.xml
    - source: https://s3.amazonaws.com/{{ salt.pillar.get('pwm:lookup:config_bucket') }}/PwmConfiguration.xml
    - source_hash: https://s3.amazonaws.com/{{ salt.pillar.get('pwm:lookup:config_bucket') }}/PwmConfiguration.xml.sha1

change_pwm_config_owner:
  file.managed:
    - name: /usr/share/tomcat/webapps/ROOT/WEB-INF/PwmConfiguration.xml
    - user: tomcat
    - group: tomcat
    - mode: 600
    - replace: False

get_sasl_password:
  file.managed:
    - name: /etc/postfix/sasl_passwd
    - source: https://s3.amazonaws.com/{{ salt.pillar.get('pwm:lookup:config_bucket') }}/sasl_passwd
    - source_hash: https://s3.amazonaws.com/{{ salt.pillar.get('pwm:lookup:config_bucket') }}/sasl_passwd.md5

change_sasl_permissions:
  file.managed:
    - name: /etc/postfix/sasl_passwd
    - mode: 600
    - replace: False

stop_tomcat_service:
  service.dead:
    - name: tomcat

sleep_before_restarting_tomcat:
  cmd.run:
    - name: sleep 3

config_start_tomcat_service:
  service.running:
    - name: tomcat
    - enable: True
    - reload: True

create_pwm_config_mgmt_script:
  file.managed:
    - name: /usr/local/bin/pwmconfmgmt.sh
    - source: salt://files/configfile/pwmconfmgmt.sh
    - template: jinja
    - mode: 700

create_inotify_pwm_config_script:
  file.managed:
    - name: /usr/local/bin/inotifypwmconfig.sh
    - source: salt://files/configfile/inotifypwmconfig.sh
    - mode: 700

execute_inotify_script:
  cmd.run:
    - name: at now + 20 minutes -f /usr/local/bin/inotifypwmconfig.sh

get_postfix_config_script:
  file.managed:
    - name: /usr/local/bin/postfix_conf.sh
    - source: https://s3.amazonaws.com/{{ salt.pillar.get('pwm:lookup:config_bucket') }}/postfix_conf.sh
    - source_hash: https://s3.amazonaws.com/{{ salt.pillar.get('pwm:lookup:config_bucket') }}/postfix_conf.sh.sha1

change_postfix_config_permissions:
  file.managed:
    - name: /usr/local/bin/postfix_conf.sh
    - mode: 700
    - replace: False

temporary_sleep_for_postfix:
  cmd.run:
    - name: sleep 5

execute_postfix_config_script:
  cmd.run:
    - name: /usr/local/bin/postfix_conf.sh

postmap_sasl:
  cmd.run:
    - name: postmap /etc/postfix/sasl_passwd

selinux_java_tolcl_postfix:
  cmd.run:
    - name: setsebool -P nis_enabled 1

start_postfix_service:
  service.running:
    - name: postfix
    - enable: True
