#!/bin/bash

export PGPASSWORD=$POSTGRESQL_ADMIN_PASSWORD
TMP_DIR=$BACKUP_DATA_DIR/_tmp

mkdir -p $TMP_DIR

function backup_db {
  DB=$1
  DATE=$(date +%Y-%m-%d-%H-%M)

  pg_dump --username=$POSTGRESQL_ADMIN_USER --host=$POSTGRESQL_SERVICE_HOST --port=$POSTGRESQL_SERVICE_PORT $DB > $TMP_DIR/$DB-dump.sql

  if [ $? -ne 0 ]; then
    echo "db-dump for ${DB} not successful: ${DATE}"
    exit 1
  fi

  mkdir -p $BACKUP_DATA_DIR/$DB
  gzip -c $TMP_DIR/$DB-dump.sql > $BACKUP_DATA_DIR/$DB/dump-${DATE}.sql.gz

  if [ $? -eq 0 ]; then
    echo "backup of db ${DB} created: ${DATE}"
  else
    echo "backup for db ${DB} not successful: ${DATE}"
    exit 1
  fi

  # Delete old files
  old_dumps=$(ls -1 $BACKUP_DATA_DIR/$DB/dump* | head -n -$BACKUP_KEEP)
  if [ "$old_dumps" ]; then
    echo "Deleting: $old_dumps"
    rm $old_dumps
  fi
}

function cleanup {
  rm -f $TMP_DIR/*
}

databases=`psql --username=$POSTGRESQL_ADMIN_USER --host=$POSTGRESQL_SERVICE_HOST --port=$POSTGRESQL_SERVICE_PORT -lt | grep -v : | cut -d \| -f 1 | grep -v template | grep -v -e '^\s*$' | sed -e 's/  *$//'|  tr '\n' ' '`

for db in $databases; do
  backup_db $db
done

trap cleanup EXIT
