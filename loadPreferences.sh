#!/bin/sh

PREFS_DIR=${PREFERENCES_DIR:-/home/node/universal/testData/preferences}

log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

if [ -z "$COUCHDB_URL" ]; then
  echo "COUCHDB_URL environment variable must be defined"
  exit 1
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
