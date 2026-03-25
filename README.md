# fundglos-pipeline
A basic data pipeline supporting analysis of grants and procurements, originally designed for fundglos.org.uk

## Usage

At the present moment you will need to run each script individually to fetch and transform various pieces. Eventually this will be replaced by a wrapper script which should build the entire pipeline.

Run each script from the root directory of this repo, as they assume this when writing output.

The scripts will create a `pipeline` directory with three subdirectories:

* `source_data`: data fetched from elsewhere, generally in the format that it was fetched in
* `intermediate_data`: various bits of "cleaned" or "remapped" data go here, ready to be combined
* `output_data`: the final output. This should really only be a single .jsonl file representing the combined output of the sources after they have been enriched. There may also be some metrics placed here.

## Step 1: Get data from sources and remap it

In general, each source will have a transform and a map script

1. `.scripts/fetch-fundglos-local-authority-grant-data.sh`
2. `.scripts/fetch-threesixtygiving-datastore-grants.sh` This one takes a while
3. `.scripts/transform-datastore-grants-to-shared-format.sh`
4. `.scripts/transform-fundglos-la-grants-to-shared-format.sh`

etc.

## Step 2: Enrich with classifications

Enriching with classifications is done by fetching some classification mappings from UK-CAT and then generating a classifications lookup file. Using this, the transformed data from each source is then passed through this lookup to append any classifications based on known identifiers in the mapped data.

Lookups like this are expensive and grow more expensive the larger the lookup table gets, so it is important to understand that the source data should be fetched and transformed *BEFORE* the classification is compiled. This is because we can get a list of unique org-ids from the dataset and use that to pre-filter the UK-CAT mappings so that only the ones for organisations we have make it into the lookup.

This will take the final compile time down from 3.6 hours to a matter of seconds or minutes (the time will grow the more grants/procurements we have)

1. `.scripts/fetch-uk-cat-classifications.sh`
2. `.scripts/get-list-of-org-ids-from-dataset.sh`
3. `.scripts/transform-uk-cat-classifications.sh`
4. `.scripts/compile-org-id-classification-lookup.sh`
5. `.scripts/add-org-classifications-to-funding-opportunities-from-lookup.sh` Final Step! This one takes a while

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
