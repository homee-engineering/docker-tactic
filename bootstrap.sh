#!/bin/bash
set -e

printf "Host: %s\n" "$PGHOST"
printf "Port: %s\n" "$PGPORT"
printf "User: %s\n" "$PGUSER"

# until pg_isready -h $PGHOST -p $PGPORT -U $PGUSER
# do
#   echo "Waiting... for $PGHOST"
#   sleep 2;
# done

while ! nc -z $PGHOST $PGPORT; do sleep 3; done

if [ "$( psql -tAc "SELECT 1 FROM pg_database WHERE datname='sthpw'" )" = '1' ]; then
    echo "Database 'sthpw' found."
else
    createdb -h $PGHOST -U $PGUSER -p $PGPORT -E UNICODE -e "sthpw"
fi

echo "INSTALLING TACTIC..."
rm -rf /tactic
git clone -b "hutch-4.5" --depth 1 https://fca79a5c03d66de2f97f586540908cc718706f49:x-oauth-basic@github.com/homee-engineering/TACTIC.git /tactic
su -c 'yes | python /tactic/src/install/install.py -d'  - apache
cp /home/apache/tactic_data/config/tactic.conf /etc/httpd/conf.d/
rm -r /tactic
echo "TACTIC INSTALL COMPLETE."

# Set root password
if [[ -n "$ROOT_PASSWORD" ]]; then 
    echo "root:${ROOT_PASSWORD}" | chpasswd
fi

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
