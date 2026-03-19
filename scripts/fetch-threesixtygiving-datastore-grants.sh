#!/usr/bin/env bash

# This script fetches the required grants from an instance of the 360Giving datastore.
# The output of this script will be a large JSONL file containing the results of the query
# It uses environment variables to control access to the postgres instance inside the datastore. So make sure you've sourced your `.env` file properly!

destination_dir="pipeline/source_data/threesixtygiving-datastore"
query_file="scripts/sql/360g-datastore-extract-grants-and-additional-data-with-location-in-gloucestershire.sql"
#query_file="scripts/sql/test-with-limited-grants.sql"

mkdir -p "$destination_dir"

# Set --tuples-only and --no-align to avoid polluting the output file with cruft and we get beautiful JSONL
psql --file="$query_file" --output="$destination_dir/datastore-grants.jsonl" --tuples-only --no-align
