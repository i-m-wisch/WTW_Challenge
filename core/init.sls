# CORE state applied to all master and nginx nodes
# - Ensure system packages are at latest versions
# - Install python-m2crypto for Salt x509 state
# - Create CA cert directory and copy CA cert from mine
# - Add Base set of IPTables rules:
#   - allow inbound SSH traffic
#   - local/loopback traffic is allowed
#   - set default posture to block inbound traffic

update-base:
  pkg.uptodate:
    - refresh: True
python-m2crypto:
  pkg.installed: []
/usr/local/share/ca-certificates:
  file.directory
/usr/local/share/ca-certificates/intca.crt:
  x509.pem_managed:
    - text: {{ salt['mine.get']('master', 'x509.get_pem_entries')['master']['/root/sslfiles/master-ca-cert.pem']|replace('\n', '') }}
    - require:
      - pkg: python-m2crypto
iptables_allow_localhost:
  iptables.insert:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - in-interface: lo
    - position: 1
    - save: True
iptables_allow_ssh:
  iptables.insert:
    - table: filter
    - chain: INPUT
    - position: 2
    - protocol: tcp
    - dport: 22
    - jump: ACCEPT
    - save: True
iptables_allow_established:
  iptables.insert:
    - table: filter
    - chain: INPUT
    - position: 3
    - match: conntrack
    - ctstate: 'RELATED,ESTABLISHED'
    - jump: ACCEPT
    - save: True
configure_iptables_policy:
  iptables.set_policy:
    - table: filter
    - chain: INPUT
    - policy: DROP
    - require:
      - iptables: iptables_allow_established
      - iptables: iptables_allow_ssh
