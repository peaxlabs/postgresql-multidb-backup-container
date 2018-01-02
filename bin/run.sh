#!/bin/sh
mkdir -p $BACKUP_DATA_DIR

echo "Checking database connection to host $POSTGRESQL_SERVICE_HOST..."
export PGPASSWORD=$POSTGRESQL_ADMIN_PASSWORD
psql --username=$POSTGRESQL_ADMIN_USER --host=$POSTGRESQL_SERVICE_HOST --port=$POSTGRESQL_SERVICE_PORT -d postgres -t -c "SELECT version();"
if [ $? -eq 0 ]; then
  echo "Connection OK."
else
  echo "Connection FAILED. Continuing anyway..."
fi


echo "Starting cron job for regular backups..."
echo "$BACKUP_MINUTE $BACKUP_HOUR * * * /opt/app-root/src/bin/job.sh" > /opt/app-root/src/crontab
devcron.py /opt/app-root/src/crontab
