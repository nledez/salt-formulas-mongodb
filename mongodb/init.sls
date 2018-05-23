{%- set packages_upgrade = salt['pillar.get']('packages_upgrade', False) %}
{%- if packages_upgrade %}
{%- set pkg_install_or_latest = 'latest' %}
{%- else %}
{%- set pkg_install_or_latest = 'installed' %}
{%- endif %}

{%- set key_file = salt['pillar.get']('mongodb:key_file', False) %}

mongodb:
  pkg.{{ pkg_install_or_latest }}:
    - pkgs:
      - mongodb
      - mongodb-clients
      - mongodb-server
  service.running:
    - enable: True
    - reload: False
    - require:
      - file: /etc/mongodb.conf
    - watch:
      - file: /etc/mongodb.conf

/etc/mongodb.conf:
  file.managed:
    - source: salt://mongodb/mongodb.conf.j2
    - user: root
    - group: root
    - mode: 444
    - template: jinja
    - require:
      - pkg: mongodb

{%- if key_file %}
/etc/ssl/mongodb-keyfile:
  file.managed:
    - contents_pillar: mongodb:key_file
    - user: mongodb
    - group: root
    - mode: 400
    - require:
      - pkg: mongodb
    - watch_in:
      - service: mongodb
{%- endif %}
