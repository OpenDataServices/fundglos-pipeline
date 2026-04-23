# fundglos-pipeline
A basic data pipeline supporting analysis of grants and procurements, originally designed for fundglos.org.uk

## Usage

Make sure you set up your `.env` file properly.

You can run each script at the top-level of the `scripts` directory, in the order that they are named.

The scripts have been designed as if they are being run from the root directory of this repo. E.g.

```bash
./scripts/1_fetch-source-data.sh
./scripts/2_transform-source-data-to-shared-format.sh
# etc..
```

You could even run the entire pipeline with bash globbing… since the scripts are named for the order that you would need to run them.

```bash
./scripts/*.sh
```

## Step 3: Final transforms and/or uploading elsewhere

Now you will have a single (large) file of all the data inside of `pipeline/output_data/funding-data.jsonl`.

You can use it how you want, but it is designed to be flattened and fed to a DeepNote notebook for analysis/visualisation:

```bash
# Inside pipeline/output_data

# flatten-tool doesn't like JSONL and instead wants things to be inside an array
jq --slurp '{funding: .}' funding-data.jsonl > funding-data-in-array.json

# This will take a little while for lots of data
flatten-tool flatten --main-sheet-name "funding_opportunities" --root-list-path "funding" --output-format all funding-data-in-array.json
```

## Requirements

### Packages

You should have the following packages in your environment:

* psql
* jq
* csvkit
* curl
* python3
  * pandas

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
