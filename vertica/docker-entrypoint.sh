#!/bin/bash
set -e

STOP_LOOP="false"

# if VERTICA_DBA_PASSWORD is provided, use it as DB password, otherwise empty password
if [ -n "$VERTICA_DBA_PASSWORD" ]; then
  export DBPW="-p $VERTICA_DBA_PASSWORD" VSQLPW="-w $VERTICA_DBA_PASSWORD";
  else export DBPW="" VSQLPW="";
fi

# Vertica should be shut down properly
function shut_down() {
  echo "Shutting Down"
  vertica_proper_shutdown
  echo 'Saving configuration'
  mkdir -p $VERTICA_DATA/config
  /bin/cp /opt/vertica/config/admintools.conf $VERTICA_DATA/config/admintools.conf
  echo 'Stopping loop'
  STOP_LOOP="true"
}

function vertica_proper_shutdown() {
  echo 'Vertica: Closing active sessions'
  /bin/su - $VERTICA_DBA_USER -c "/opt/vertica/bin/vsql -U $VERTICA_DBA_USER -d $VERTICA_DATABASE_NAME $VSQLPW -c 'SELECT CLOSE_ALL_SESSIONS();'"
  echo 'Vertica: Flushing everything on disk'
  /bin/su - $VERTICA_DBA_USER -c "/opt/vertica/bin/vsql -U $VERTICA_DBA_USER -d $VERTICA_DATABASE_NAME $VSQLPW -c 'SELECT MAKE_AHM_NOW();'"
  echo 'Vertica: Stopping database'
  /bin/su - $VERTICA_DBA_USER -c "/opt/vertica/bin/admintools -t stop_db $DBPW -d $VERTICA_DATABASE_NAME -i"
}

function fix_filesystem_permissions() {
  chown -R $VERTICA_DBA_USER:verticadba "$VERTICA_DATA"
  chown $VERTICA_DBA_USER:verticadba /opt/vertica/config/admintools.conf
}

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT

echo "Starting up"
if [ ! -f $VERTICA_DATA/config/admintools.conf ]; then
  echo 'Fixing filesystem permissions'
  fix_filesystem_permissions
  echo 'Creating database'
  su - $VERTICA_DBA_USER -c "/opt/vertica/bin/admintools -t create_db --skip-fs-checks -s localhost -d $VERTICA_DATABASE_NAME $DBPW -c $VERTICA_DATA/catalog -D $VERTICA_DATA/data"
else
  echo 'Restoring configuration'
  cp $VERTICA_DATA/config/admintools.conf /opt/vertica/config/admintools.conf
  echo 'Fixing filesystem permissions'
  fix_filesystem_permissions
  echo 'Starting Database'
  su - $VERTICA_DBA_USER -c "/opt/vertica/bin/admintools -t start_db -d $VERTICA_DATABASE_NAME $DBPW --noprompts --timeout=never"
fi

echo
if [ -d /docker-entrypoint-initdb.d/ ]; then
  echo "Running entrypoint scripts ..."
  for f in $(ls /docker-entrypoint-initdb.d/* | sort); do
    case "$f" in
      *.sh)     echo "$0: running $f"; . "$f" ;;
      *.sql)    echo "$0: running $f"; su - $VERTICA_DBA_USER -c "/opt/vertica/bin/vsql -d $VERTICA_DATABASE_NAME $VSQLPW -f $f"; echo ;;
      *)        echo "$0: ignoring $f" ;;
    esac
   echo
  done
fi

echo
echo "Vertica is now running"

while [ "${STOP_LOOP}" == "false" ]; do
  sleep 1
done
