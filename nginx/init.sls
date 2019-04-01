# NGINX configuration
# - ensure package is installed and running
# - open 80 and 3200 ports inbound through firewall
# - configure and enable proxy (3200) and source (3400) server blocks
# - drop source and 404 index files
# - restart service on server config changes

nginx:
  pkg.installed: []
  iptables.append:
    - table: filter
    - chain: INPUT
    - protocol: tcp
    - dports: '80,3200'
    - jump: ACCEPT
    - save: True
generate_cert_and_key:
  x509.certificate_managed:
    - name: /etc/nginx/certs/example.com.crt
    - ca_server: master
    - signing_policy: www
    - public_key: /etc/nginx/certs/example.com.crt
    - CN: www.example.com
    # Bunk SAN to work around https://github.com/saltstack/salt/issues/51869
    - subjectAltName: 'RID:1.2.3.4'
    - days_remaining: 10
    - makedirs: True
    - backup: True
    - managed_private_key:
        name: /etc/nginx/certs/example.com.key
        backup: True
        makedirs: True
{% for vhost in 'example.com','localhost' %}
{{ vhost }}_vhost_conf:
  file.managed:
    - name: /etc/nginx/sites-available/{{ vhost }}
    - source: salt://nginx/{{ vhost }}
    - mode: 0644
    - user: root
    - group: root
{{ vhost }}_vhost_enable:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ vhost }}
    - name: /etc/nginx/sites-enabled/{{ vhost }}
    - require:
      - file: /etc/nginx/sites-available/{{ vhost }}
{% endfor %}
{% for index in 'localhost','404' %}
{{ index }}_index_html:
  file.managed:
    - source: salt://nginx/{{ index }}_index.html
{% if index == 'localhost' %}
    - name: /var/www/localhost/index.html
{% elif index == '404' %}
    - name: /var/www/html/index.html
{% endif %}
    - makedirs: True
    - clean: True
    - dir_mode: 0755
    - mode: 0644
    - user: root
    - group: root
{% endfor %}
server_tokens_off:
  file.line:
    - name: /etc/nginx/nginx.conf
    - content: 'server_tokens off;'
    - match: '.*server_tokens.*'
    - mode: replace
    - indent: True
enable_nginx:
  service.running:
    - name: nginx
    - enable: True
    - require:
      - pkg: nginx
    - watch:
      - file: /etc/nginx/sites-available/localhost
      - file: /etc/nginx/sites-available/example.com
      - file: /etc/nginx/nginx.conf
