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

You will also need access to the 360Giving datastore, or deploy your own instance of it.

* You can gain access to the hosted 360Giving datastore by following 360Giving's [official guidance](https://www.360giving.org/explore/technical/datastore/).
* You can host your own instance of the datastore by following the instructions in the README of [threesixtygiving/datastore](https://github.com/threeSixtyGiving/datastore/). Once set up, you will need to trigger a load to get the data. A load takes a few hours.


#### Step 1. Set up the `.env` file

This repo accesses the Postgres database on the datastore via the `psql` program, and the access details are provided by a combination of environment variables and a password file that **should not** be checked into any instance of this repo.

Create a `.env` file in the root directory of this repo, which looks like this:

```bash
PGDATABASE='your-database-here' # If using the hosted 360Giving datastore, this should be 360givingdatastore
PGHOST='datastore.example.org' # If using the hosted 360Giving datastore, this should be store.data.threesixtygiving.org
PGUSER='my-username' # If using the hosted 360Giving datastore, this should be colab_notebooks30
PGPASSFILE='.pgpass' # This should point to a file containing the password for the postgres instance. See https://www.postgresql.org/docs/18/libpq-pgpass.html for full details

export PGDATABASE PGHOST PGUSER PGPASSFILE
```

#### Step 2. Set up the `.pgpass` file

Create a `.pgpass` file in the root directory, which should look like this:

```
domain.of.your.datastore.instance:*:*:username-for-your-datastore-instance:your-password
```

Psql likes its password files to be relatively secure, so you'll likely need to change the permissions to stop unauthorised reading. This is easily done with `chmod 0600 .pgpass`. See [the postgres docs](https://www.postgresql.org/docs/18/libpq-pgpass.html) for a full reference.
