# sets up the iptables for the machine
input_accept_policy:
  iptables.set_policy:
    - chain: INPUT
    - policy: ACCEPT

flush_input:
  iptables.flush:
    - chain: INPUT

loopback_all:
  iptables.append:
    - family: ipv4
    - chain: INPUT
    - jump: ACCEPT
    - comment: "Allow inbound on loopback for app to postfix mailing"
    - in-interface: lo

all_conn_state:
  iptables.append:
    - chain: INPUT
    - match: state
    - connstate: RELATED,ESTABLISHED
    - jump: ACCEPT

allow_ssh_all:
  iptables.append:
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - dport: 22
    - jump: ACCEPT

dest_80_all:
  iptables.append:
    - family: ipv4
    - chain: INPUT
    - jump: ACCEPT
    - comment: "Allow HTTP"
    - dport: 80
    - proto: tcp

dest_8080_all:
  iptables.append:
    - family: ipv4
    - chain: INPUT
    - jump: ACCEPT
    - comment: "Allow access to Tomcat Mgmt 8080"
    - dport: 8080
    - proto: tcp

input_drop_policy:
  iptables.set_policy:
    - chain: INPUT
    - policy: DROP
    - save: True