echo 'set realname="The PWM"' >> /root/.muttrc
mailfromdomain="{{ salt.pillar.get('pwm:lookup:mailfromdomain') }}"
echo 'set from="pwm@'$mailfromdomain'"' >> /root/.muttrc
echo 'set use_from = yes' >> /root/.muttrc
echo 'set edit_headers = yes' >> /root/.muttrc
echo 'set use_envelope_from = yes' >> /root/.muttrc