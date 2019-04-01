# - Ensure default salt-master ports are open.
# - Configure certificate signing policy.
# - Upload CA crt to mine

iptables_allow_salt:
  iptables.append:
    - table: filter
    - chain: INPUT
    - protocol: tcp
    - dports: '4505,4506'
    - jump: ACCEPT
    - save: True
salt-minion:
  service.running:
    - enable: True
    - listen:
      - file: /etc/salt/minion.d/signing_policies.conf
/etc/salt/minion.d/signing_policies.conf:
  file.managed:
    - source: salt://saltmaster/signing_policies.conf
mine.send:
  module.run:
    - func: x509.get_pem_entries
    - args: ["/root/sslfiles/master-ca-cert.pem"]
