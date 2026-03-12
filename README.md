# fundglos-pipeline
A basic data pipeline supporting analysis of grants and procurements, originally designed for fundglos.org.uk


## Requirements

### Packages

You should have the following packages in your environment:

* psql
* jq
* csvkit (specifically csvcut, csvjoin, and csvjson)
* curl

### Datastore Access

You will also need access to the 360Giving datastore, or deploy your own instance of it. (TODO: add instructions for this).

The access for the datastore should be stored in environment variables in a `.env` file.

* `PGHOST`: the url for the instance of the datastore
* `PGPORT`: the port for the instance of the datastore
* `PGDATABASE`: the database name for the instance of the datastore you're using, which should usually be `360givingdatastore`
* `PGUSER`: the username for the user of the datastore instance
* `PGPASS`: the password for that user of the instance of the datastore you're using
