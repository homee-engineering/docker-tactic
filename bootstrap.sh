#!/bin/bash
set -e

git clone -b "hutch-4.5" --depth 1 https://fca79a5c03d66de2f97f586540908cc718706f49@github.com/homee-engineering/TACTIC.git
yes | python TACTIC/src/install/install.py -d 
cp /home/apache/tactic_data/config/tactic.conf /etc/httpd/conf.d/
rm -r TACTIC

# Set root password
if [[ -n "$ROOT_PASSWORD" ]]; then 
    echo "root:${ROOT_PASSWORD}" | chpasswd
fi

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
