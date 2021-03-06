#installs packages needed for PWM, downloads the WAR file and installs it into tomcat
install_packages:
  pkg.installed:
    - names:
      - java-1.8.0-openjdk
      - tomcat
      - wget
      - unzip
      - httpd
      - inotify-tools
      - s3cmd
      - at
      - postfix
      - cyrus-sasl-plain
      - chrony
      - python-setuptools
      - python2-pip

install_aws_cli:
  pip.installed:
    - name: awscli

remove_unused_packages:
  pkg.removed:
    - names:
      - ntp
      - ntpdate

retrieve_war_file:
  file.managed:
    - name: /usr/share/tomcat/webapps/ROOT.war
    - source: s3://{{ salt.pillar.get('pwm:lookup:config_bucket') }}/pwm18.war
    - skip_verify: True

change_war_file_ownership:
  file.managed:
    - name: /usr/share/tomcat/webapps/ROOT.war
    - user: tomcat
    - group: tomcat
    - replace: False

start_tomcat_service:
  service.running:
    - name: tomcat
    - enable: True
    - reload: True

restart_tomcat_service:
  service.running:
    - name: tomcat
    - enable: True
    - reload: True

append_to_pwm.conf:
  file.append:
    - name: /etc/httpd/conf.d/pwm.conf
    - source: salt://files/install/pwm.conf

start_httpd_service:
  service.running:
    - name: httpd
    - enable: True

start_atd_service:
  service.running:
    - name: atd
    - enable: True

{%- if salt.selinux.getenforce() in ['Enforcing', 'Permissive'] %}
chcon_selinuxproxy:
  cmd.run:
    - name: chcon -R --reference=/usr/share/tomcat/webapps /usr/share/tomcat/webapps/ROOT.war
  selinux.boolean:
    - name: httpd_can_network_relay
    - value: True
    - persist: True
{% endif %}

pwm_app_path:
  file.blockreplace:
    - name: /usr/share/tomcat/webapps/ROOT/WEB-INF/web.xml
    - marker_start: "        <param-name>applicationPath</param-name>"
    - marker_end: "    </context-param>"
    - content: "        <param-value>/usr/share/tomcat/webapps/ROOT/WEB-INF</param-value>"
    - show_changes: True
    - backup: '.bak'

append_to_tomcat.conf:
  file.append:
    - name: /usr/share/tomcat/conf/tomcat.conf
    - source: salt://files/install/tomcat.conf

append_to_chrony.conf:
  file.append:
    - name: /etc/chrony.conf
    - source: salt://files/install/chrony.conf

create_hostname_script:
  file.managed:
    - name: /usr/local/bin/rerunhostnamestate
    - source: salt://files/install/rerunhostnamestate.sh
    - mode: "0744"

execute_hostname_state:
  cmd.run:
    - name: at now + 10 minutes -f /usr/local/bin/rerunhostnamestate
