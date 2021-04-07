#!/bin/bash
set -e

STOP_LOOP="false"

# if vars DBA_USER, DATABASE_NAME is not provided use default
# export DBA_USER="${DBA_USER:-dbadmin}"
# export DATABASE_NAME="${DATABASE_NAME:-test}"

# if DBA_PASSWORD is provided, use it as DB password, otherwise empty password
if [ -n "$DBA_PASSWORD" ]; then
  export DBPW="-p $DBA_PASSWORD" VSQLPW="-w $DBA_PASSWORD";
  else export DBPW="" VSQLPW="";
fi

# Vertica should be shut down properly
function shut_down() {
  echo "Shutting Down"
  vertica_proper_shutdown
  echo 'Saving configuration'
  mkdir -p $VERTICADATA/config
  /bin/cp /opt/vertica/config/admintools.conf $VERTICADATA/config/admintools.conf
  echo 'Stopping loop'
  STOP_LOOP="true"
}

function vertica_proper_shutdown() {
  echo 'Vertica: Closing active sessions'
  /bin/su - $DBA_USER -c "/opt/vertica/bin/vsql -U $DBA_USER -d $DATABASE_NAME $VSQLPW -c 'SELECT CLOSE_ALL_SESSIONS();'"
  echo 'Vertica: Flushing everything on disk'
  /bin/su - $DBA_USER -c "/opt/vertica/bin/vsql -U $DBA_USER -d $DATABASE_NAME $VSQLPW -c 'SELECT MAKE_AHM_NOW();'"
  echo 'Vertica: Stopping database'
  /bin/su - $DBA_USER -c "/opt/vertica/bin/admintools -t stop_db $DBPW -d $DATABASE_NAME -i"
}

function fix_filesystem_permissions() {
  chown -R $DBA_USER:verticadba "$VERTICADATA"
  chown $DBA_USER:verticadba /opt/vertica/config/admintools.conf
}

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT


echo "Starting up"
if [ ! -f $VERTICADATA/config/admintools.conf ]; then
  echo 'Fixing filesystem permissions'
  fix_filesystem_permissions
  echo 'Creating database'
  su - $DBA_USER -c "/opt/vertica/bin/admintools -t create_db --skip-fs-checks -s localhost -d $DATABASE_NAME $DBPW -c $VERTICADATA/catalog -D $VERTICADATA/data"
else
  echo 'Restoring configuration'
  cp $VERTICADATA/config/admintools.conf /opt/vertica/config/admintools.conf
  echo 'Fixing filesystem permissions'
  fix_filesystem_permissions
  echo 'Starting Database'
  su - $DBA_USER -c "/opt/vertica/bin/admintools -t start_db -d $DATABASE_NAME $DBPW --noprompts --timeout=never"
fi

echo
if [ -d /docker-entrypoint-initdb.d/ ]; then
  echo "Running entrypoint scripts ..."
  for f in $(ls /docker-entrypoint-initdb.d/* | sort); do
    case "$f" in
      *.sh)     echo "$0: running $f"; . "$f" ;;
      *.sql)    echo "$0: running $f"; su - $DBA_USER -c "/opt/vertica/bin/vsql -d $DATABASE_NAME $VSQLPW -f $f"; echo ;;
      *)        echo "$0: ignoring $f" ;;
    esac
   echo
  done
fi

echo
echo "Vertica is now running"
echo
echo === settings =============================================
echo "VERTICA_PACKAGE"=$VERTICA_PACKAGE
echo "VERTICA_DBA_USER"=$VERTICA_DBA_USER
echo "VERTICA_DBA_PASSWORD"=$VERTICA_DBA_PASSWORD
echo "VERTICA_DATABASE_NAME"=$VERTICA_DATABASE_NAME
echo ==========================================================

while [ "${STOP_LOOP}" == "false" ]; do
  sleep 1
done
