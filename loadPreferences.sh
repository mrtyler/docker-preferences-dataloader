#!/bin/sh

PREFS_DIR=${PREFERENCES_DIR:-/home/node/universal/testData/preferences}

log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

if [ -z "$COUCHDB_URL" ]; then
  if [ -z "$COUCHDB_USER" ]; then
    echo "COUCHDB_USER environment variable must be defined"
    exit 1
  fi
  if [ -z "$COUCHDB_PASSWORD" ]; then
    echo "COUCHDB_PASSWORD environment variable must be defined"
    exit 1
  fi
  if [ -z "$COUCHDB_PROTOCOL" ]; then
    echo "COUCHDB_PROTOCOL environment variable must be defined"
    exit 1
  fi
  if [ -z "$COUCHDB_HOSTPATH" ]; then
    echo "COUCHDB_HOSTPATH environment variable must be defined"
    exit 1
  fi
  COUCHDB_URL="$COUCHDB_PROTOCOL://$COUCHDB_USER:$COUCHDB_PASSWORD@$COUCHDB_HOSTPATH"
fi

log "Starting"

if [ ! -z "$CLEAR_INDEX" ]; then
  log "Deleting database at $COUCHDB_URL"
  if ! curl -fsS -X DELETE "$COUCHDB_URL"; then
    log "Error deleting database"
  fi
fi

log "Creating database at $COUCHDB_URL"
if ! curl -fsS -X PUT "$COUCHDB_URL"; then
  log "Error creating database"
  exit 1
fi

# Submit preferences
for file in $PREFS_DIR/*.json; do
  FILENAME=$(basename "$file" .json)
  DATA="{ \"_id\":\"$FILENAME\", \"value\":$(cat "$file") }"

  log "Submitting $FILENAME.json"
  if ! curl -fsS -q -H 'Content-Type: application/json' -X POST "$COUCHDB_URL" -d "$DATA"; then
    log "Error submitting $FILENAME. Terminating."
    exit 1
  fi

done
