# This is currently intended for ec2 hosts that come with sth like ip-10-10-0-123 for a hostname.
# To match the hostname with the entries created by the hostsfile state, also execute this state.
{%- set fqdn = grains['nodename'] %}
{%- set localip = grains['ipv4'] %}

system:
  network.system:
    - hostname: {{ fqdn }}
    - apply_hostname: True
    - retain_settings: True

ensure_self_in_hosts_file:
  host.present:
    - ip: {{ localip }}
    - names:
      - {{ fqdn }}
    - clean: True
