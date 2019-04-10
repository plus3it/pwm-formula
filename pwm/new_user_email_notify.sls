{%- if salt.pillar.get('pwm:lookup:new_user_email_notify') == 1 %}
mailer_install:
  pkg.installed:
    - names:
      - mutt
      - jq

create_watchnewuser_script:
  file.managed:
    - name: /usr/local/bin/watchnewuser.sh
    - source: salt://files/new_user_email_notify/watchnewuser.sh
    - template: jinja
    - mode: 700

append_email_origination:
  file.append:
    - name: /usr/local/bin/emailsniporig.html
    - source: salt://files/new_user_email_notify/emailsniporig.html   

create_emailpart1_html:
  file.managed:
    - name: /usr/local/bin/emailpart1.html
    - source: salt://files/new_user_email_notify/emailpart1.html
    - template: jinja
    - mode: 700 

create_emailpart2_html:
  file.managed:
    - name: /usr/local/bin/emailpart2.html
    - source: salt://files/new_user_email_notify/emailpart2.html
    - template: jinja
    - mode: 700   

create_createmuttrc_script:
  file.append:
    - name: /usr/local/bin/createmuttrc.sh
    - template: jinja
    - source: salt://files/new_user_email_notify/createmuttrc.sh

change_createmuttrc_permissions:
  file.managed:
    - name: /usr/local/bin/createmuttrc.sh
    - mode: 700
    - replace: False

execute_createmuttrc_script:
  cmd.run:
    - name: /usr/local/bin/createmuttrc.sh

email_start_crond_service:
  service.running:
    - name: crond
    - enable: True
{% endif %}