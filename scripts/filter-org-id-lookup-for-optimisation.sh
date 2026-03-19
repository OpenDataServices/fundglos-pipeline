#!/usr/bin/env bash

# This script runs a jq command which takes the list of unique org-ids in the total dataset, and then filters the lookup table to those only within the the dataset. This hopefully makes adding classifications to the data much faster at a later stage in the pipeline

classifications_file="pipeline/intermediate_data/org-classifications/classifications-lookup.jsonl"
jq_filter="scripts/jq/filter-classifications-for-optimisation.jq"
org_id_list_file="pipeline/intermediate_data/org-classifications/list-of-unique-org-ids-in-data.txt"
destination_dir="pipeline/intermediate_data/org-classifications"

jq --compact-output --rawfile ids "$org_id_list_file"  --from-file "$jq_filter" > "$destination_dir/filtered-classification-lookup.jsonl"
