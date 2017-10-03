# postgresql-multidb-backup-container
Provide a PostgreSQL database backup container that does backups using a cron job. The backup is done by the `pg_dump` tool.

## Different PostgreSQL versions
Backup for different PostgreSQL database versions are provided:
* 9.5
* 9.4
* 9.2

Use the Docker file with the postfix of your desired PostgreSQL version.

## How to deploy the backup container

### Deploy by OpenShift template
Use the **postgresql-backup-persistent-template.json** template for production.
It will claim a persistent volume to store the backups.

The **ephemeral** template is only more for testing or extend it to store the backup outside of OpenShift.  

```
$ oc process -f postgresql-backup-persistent-template.json \
    -l app=backup \
    -v \
    POSTGRESQL_ADMIN_PASSWORD=pw \
    POSTGRESQL_SERVICE_HOST=postgres \
    BACKUP_DATA_DIR=/opt/backup \
| oc create -f -
```

### Deploy image from Docker Hub
Before executing the following commands make sure that you are logged into OpenShift via the commandline (`oc login`) and using the correct project (`oc project`). The postgresql service doesn't have to be located in the same project, if you can access it remotely.

```
$ oc new-app \
    -e POSTGRESQL_ADMIN_PASSWORD=pw \
    -e POSTGRESQL_SERVICE_HOST=postgres \
    -e POSTGRESQL_SERVICE_PORT=port \
    -e BACKUP_DATA_DIR=/tmp/ \
    -e BACKUP_KEEP=5 \
    -e BACKUP_MINUTE=10 \
    -e BACKUP_HOUR=11 \
    -l app=backup \
    appuio/postgresql-multidb-backup-container:9.5
```

This will create a container for backups of a PostgreSQL database 9.5. Switch PostgreSQL database version by changing the tag on the last line of the command.

### Build and deploy in OpenShift project
Before executing the following commands make sure that you are logged into OpenShift via the commandline (`oc login`) and using the correct project (`oc project`). The postgresql service doesn't have to be located in the same project, if you can access it remotely.

The first command creates the container. The second command configures the container to do backups of your databases in a desired schedule.

```
$ oc new-app https://github.com/appuio/postgresql-multidb-backup-container.git \
    --strategy=docker \
    --context-dir=Dockerfile_9.5 \
    -l app=backup

$ oc env dc postgresql-multidb-backup-container \
    -e POSTGRESQL_ADMIN_PASSWORD=pw \
    -e POSTGRESQL_SERVICE_HOST=postgres \
    -e POSTGRESQL_SERVICE_PORT=port \
    -e BACKUP_DATA_DIR=/tmp/ \
    -e BACKUP_KEEP=5 \
    -e BACKUP_MINUTE=10 \
    -e BACKUP_HOUR=11 \
    -l app=backup \
```

This will create a container for backups of PostgreSQL databases 9.5. To backup an other version, change the value of the `--context-dir` option.

**Note:** For values with comma (eg. 11,23) you will have to edit the dc with vim: `oc edit dc postgresql-multidb-backup-container`
