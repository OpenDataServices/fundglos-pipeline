#!/usr/bin/env bash

# This script takes the 360Giving format datastore grants and remaps them into the shared format via jq
# It depends on grants existing inside pipeline/source_data/threesixtygiving-datastore/datastoregrants.jsonl
# If that doesn't exist, run `fetch-threesixtygiving-datastore-grants.sh` first

datastore_grants_file="pipeline/source_data/threesixtygiving-datastore/datastore-grants.jsonl"
destination_dir="pipeline/intermediate_data/"
filter_file="scripts/jq/map-datastore-extracts-to-shared-model.jq"

mkdir -p "$destination_dir"

jq --compact-output --from-file "$filter_file" "$datastore_grants_file"
