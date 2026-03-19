#!/usr/bin/env bash

# This is an optimisation script which extracts a list of org-ids in the dataset with an aim to pare down the classification lookup time

data_dir="pipeline/intermediate_data/mapped-funding-data"
jq_filter="scripts/jq/get-org-ids-from-dataset.jq"
destination_dir="pipeline/intermediate_data/org-classifications"


cat $data_dir/*.jsonl | jq -r --from-file "$jq_filter" | sort --unique | grep -v '^null$' > "$destination_dir/list-of-unique-org-ids-in-data.txt"
