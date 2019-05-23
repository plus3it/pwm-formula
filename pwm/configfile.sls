get_pwm_config:
  file.managed:
    - name: /usr/share/tomcat/webapps/ROOT/WEB-INF/PwmConfiguration.xml
    - source: s3://{{ salt.pillar.get('pwm:lookup:config_bucket') }}/PwmConfiguration.xml
    - skip_verify: True
    - user: tomcat    
    - group: tomcat
    - mode: 600

get_sasl_password:
  file.managed:
    - name: /etc/postfix/sasl_passwd
    - source: s3://{{ salt.pillar.get('pwm:lookup:config_bucket') }}/sasl_passwd
    - skip_verify: True
    - mode: 600

config_start_tomcat_service:
  service.running:
    - name: tomcat
    - enable: True
    - reload: True
    - init_delay: 3

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
    - source: s3://{{ salt.pillar.get('pwm:lookup:config_bucket') }}/postfix_conf.sh
    - skip_verify: True
    - mode: 700

execute_postfix_config_script:
  cmd.run:
    - name: /usr/local/bin/postfix_conf.sh

postmap_sasl:
  cmd.run:
    - name: postmap /etc/postfix/sasl_passwd

selinux_java_tolcl_postfix:
  selinux.boolean:
    - name: nis_enabled
    - value: True
    - persist: True

start_postfix_service:
  service.running:
    - name: postfix
    - enable: True
