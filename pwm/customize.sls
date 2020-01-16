append_environment_welcome:
  file.append:
    - name: /usr/share/tomcat/webapps/ROOT/WEB-INF/jsp/fragment/envwelcome.jsp
    - source: salt://files/customize/envwelcome.jsp

{% set myvar = 42 %}
addenvtexttologin-{{ myvar }}:
  file.blockreplace:
    - name: /usr/share/tomcat/webapps/ROOT/WEB-INF/jsp/login.jsp
    - marker_start: "        </table>"
    - marker_end: "    </div>"
    - show_changes: True
    - backup: '.bak'

addenvtexttologin-{{ myvar }}-accumulated1:
  file.accumulated:
    - filename: /usr/share/tomcat/webapps/ROOT/WEB-INF/jsp/login.jsp
    - name: my-accumulator-{{ myvar }}
    - text: '            </pwm:if>'
    - require_in:
      - file: addenvtexttologin-{{ myvar }}

addenvtexttologin-{{ myvar }}-accumulated2:
  file.accumulated:
    - filename: /usr/share/tomcat/webapps/ROOT/WEB-INF/jsp/login.jsp
    - name: my-accumulator-{{ myvar }}
    - text: '        </pwm:if>'
    - require_in:
      - file: addenvtexttologin-{{ myvar }}

addenvtexttologin-{{ myvar }}-accumulated3:
  file.accumulated:
    - filename: /usr/share/tomcat/webapps/ROOT/WEB-INF/jsp/login.jsp
    - name: my-accumulator-{{ myvar }}
    - text: '    <%@ include file="fragment/envwelcome.jsp" %>'
    - require_in:
      - file: addenvtexttologin-{{ myvar }}

append_newuser_js:
  file.append:
    - name: /usr/share/tomcat/webapps/ROOT/public/resources/js/newuser.js
    - source: salt://files/customize/newuser.js

form_jsp_add_script:
  file.replace:
    - name: /usr/share/tomcat/webapps/ROOT/WEB-INF/jsp/fragment/form.jsp
    - pattern:        maxlength="<%=loopConfiguration.getMaximumLength.*
    - count: 1
    - repl: |{% raw %}
                maxlength="<%=loopConfiguration.getMaximumLength()%>"
                                <%if((loopConfiguration.getName().equals("sn"))||(loopConfiguration.getName().equals("initials"))||(loopConfiguration.getName().equals("givenName"))){%> onblur='autoGen(this.form.givenName.value, this.form.initials.value, this.form.sn.value)'<%}%>/>{% endraw %} # noqa: 202
