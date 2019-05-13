{%- if salt.pillar.get('pwm:lookup:new_user_api_notify') %}
new_user_notifiy_pkginstall:
  pkg.installed:
    - names:
      - php
      - jq

email_create_ostapi-newuserticket_script:
  file.managed:
    - name: /usr/local/bin/ostapi-newuserticket.php
    - source: salt://files/new_user_api_notify/ostapi-newuserticket.php
    - template: jinja
    - mode: 744

create_watchnewuser-api_script:
  file.managed:
    - name: /usr/local/bin/watchnewuser-api.sh
    - source: salt://files/new_user_api_notify/watchnewuser-api.sh
    - mode: 700

api_start_crond_service:
  service.running:
    - name: crond
    - enable: True

/etc/crontab:
  cron.present:
    - name: /usr/local/bin/watchnewuser-api.sh
    - minute: "*/1"
    - identifier: watchnewuser
{% endif %}
