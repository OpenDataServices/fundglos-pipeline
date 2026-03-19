#!/usr/bin/env bash

# This script will take all CSV files inside `pipeline/intermediate_data/org-classifications` and transform them to a JSON object for rapid lookup.

# It assumes that all the CSV files have the following columns, in the same order: 
# "org_id","code","description","scheme"

# It will first stack all the CSV files representing the classification mappings into a single giant csv file, then feed this to jq, jq will then group everything by org_id so we end up with a JSONL file of lookup objects of org_id -> an array of classifications from all the schemes. This will make it relatively rapid to add classifications to organisations in the final dataset

source_data_dir="pipeline/intermediate_data/org-classifications"
filter_file="scripts/jq/org-classifications-to-classifications-lookup.jq"

csvstack $source_data_dir/*.csv | csvjson | jq --compact-output --from-file "$filter_file" > "$source_data_dir/classifications-lookup.jsonl"
