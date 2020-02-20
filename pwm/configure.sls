get_pwm_config:
  file.managed:
    - name: /usr/share/tomcat/webapps/ROOT/WEB-INF/PwmConfiguration.xml
    - source: s3://{{ salt.pillar.get('pwm:lookup:config_bucket') }}/PwmConfiguration.xml
    - skip_verify: True
    - user: tomcat
    - group: tomcat
    - mode: "0600"

get_sasl_password:
  file.managed:
    - name: /etc/postfix/sasl_passwd
    - source: salt://files/configure/sasl_passwd.jinja
    - template: jinja
    - mode: "0600"

config_start_tomcat_service:
  service.running:
    - name: tomcat
    - enable: True
    - reload: True
    - init_delay: 3

create_pwm_config_mgmt_script:
  file.managed:
    - name: /usr/local/bin/pwmconfmgmt.sh
    - source: salt://files/configure/pwmconfmgmt.sh
    - template: jinja
    - mode: "0700"

create_inotify_pwm_config_script:
  file.managed:
    - name: /usr/local/bin/inotifypwmconfig.sh
    - source: salt://files/configure/inotifypwmconfig.sh
    - mode: "0700"

execute_inotify_script:
  cmd.run:
    - name: at now + 20 minutes -f /usr/local/bin/inotifypwmconfig.sh

postfix_pkginstall:
  pkg.installed:
    - names:
      - jq

get_postfix_main_config:
  file.managed:
    - name: /etc/postfix/main.cf
    - source: salt://files/configure/main.jinja
    - template: jinja
    - mode: "0700"

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

mv_admin_user_mgmt_file:
  file.managed:
    - name: /usr/local/bin/adminusermgmt.sh
    - source: salt://files/configure/adminusermgmt.sh
    - user: root
    - group: root
    - mode: "0700"
