#!/bin/bash
set -e

printf "Host: %s\n" "$PGHOST"
printf "Port: %s\n" "$PGPORT"
printf "User: %s\n" "$PGUSER"
printf "PW: %s\n" "$PGPASSWORD"

if [ "$( psql -tAc "SELECT 1 FROM pg_database WHERE datname='sthpw'" )" = '1' ] then
    createdb -h $PGHOST -U $PGUSER -p $PGPORT -E UNICODE "sthpw"
fi

# createdb -h $PGHOST -U $PGUSER -p $PGPORT -E UNICODE "sthpw"

rm -rf /tactic
git clone -b "hutch-4.5" --depth 1 https://fca79a5c03d66de2f97f586540908cc718706f49:x-oauth-basic@github.com/homee-engineering/TACTIC.git /tactic
yes | python /tactic/src/install/install.py -d
cp /home/tacticadmin/tactic_data/config/tactic.conf /etc/httpd/conf.d/
rm -r /tactic

# Set root password
if [[ -n "$ROOT_PASSWORD" ]]; then 
    echo "root:${ROOT_PASSWORD}" | chpasswd
fi

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
