# Setup Cron job to ensure Salt highstate is run at
# 10 minute intervals

include:
  - core

salt-call state.apply:
  cron.present:
    - identifier: SALTCRON
    - user: root
    - minute: '*/10'
