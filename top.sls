base:
  'master and G@osfinger:Ubuntu-18.04':
    - saltmaster
  '* and G@osfinger:Ubuntu-18.04':
    - core
    - core.cron
  'nginx and G@osfinger:Ubuntu-18.04':
    - nginx
