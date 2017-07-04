# Preferences Data Loader

Builds a [sidecar container](http://blog.kubernetes.io/2015/06/the-distributed-system-toolkit-patterns.html) with the preferences data from the GPII/universal repository baked in and a mechanism for loading them into a CouchDB database.

## Building

- `docker build -t gpii/preferences-dataloader .`

## Environment Variables

- `COUCHDB_URL`: URL of the CouchDB database. (required)
- `CLEAR_INDEX`: If defined, the database at $COUCHDB_URL will be deleted and recreated. (optional)
- `PREFERENCES_DIR`: This is useful if you want to mount the preferences data using a Docker volume and point the data loader at it (optional)

## Running

Example using containers:

```
$ docker run -d -p 5984:5984 --name couchdb couchdb
$ docker run --rm --link couchdb -e COUCHDB_URL=http://couchdb:5984/preferences -e CLEAR_INDEX=1 gpii/preferences-dataloader
$ docker run --name prefserver -d -p 8081:8081 --link couchdb -e NODE_ENV=gpii.preferencesServer.config.production -e COUCHDB_HOST_ADDRESS=couchdb gpii/preferences-server
```

Loading preferences data from a different location (e.g. /mydata):

```
$ docker run --rm -e COUCHDB_URL=http://couchdb:5984/preferences -e CLEAR_INDEX -e PREFERENCES_DIR=/mydata -v /home/user/mydata:/mydata gpii/preferences-dataloader
```
