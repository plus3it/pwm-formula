{%- if salt.pillar.get('pwm:lookup:enable_ost_integration') %}
ost_integration_pkginstall:
  pkg.installed:
    - names:
      - php
      - jq

monitor_new_user_creation_script:
  file.managed:
    - name: /usr/local/bin/watchnewuser-api.sh
    - source: salt://files/ost_integration/watchnewuser-api.sh
    - mode: "0700"

/etc/crontab:
  cron.present:
    - name: /usr/local/bin/watchnewuser-api.sh
    - minute: "*/1"
    - identifier: watchnewuser

generate_ost_ticket_script:
  file.managed:
    - name: /usr/local/bin/ostapi-newuserticket.php
    - source: salt://files/ost_integration/ostapi-newuserticket.php
    - template: jinja
    - mode: "0744"

api_start_crond_service:
  service.running:
    - name: crond
    - enable: True
{% endif %}
