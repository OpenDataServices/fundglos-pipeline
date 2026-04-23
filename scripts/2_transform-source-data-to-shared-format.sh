#!/usr/bin/env bash


mapped_data_dir="pipeline/intermediate_data/mapped-funding-data"

mkdir -p "$mapped_data_dir"

# Transform the 360G datastore grants to the shared format
# =========================================================

echo "Transforming 360Giving Datastore Grants…"

datastore_grants_file="pipeline/source_data/threesixtygiving-datastore/datastore-grants.jsonl"
datastore_filter_file="scripts/jq/map-datastore-extracts-to-shared-model.jq"

jq --compact-output --from-file "$datastore_filter_file" "$datastore_grants_file" > "$mapped_data_dir/datastore-grants-transformed.jsonl"

# Transform the Fundglos Data to the shared format
# ==========================================================

echo "Transforming Fundglos Data…"

fundglos_transform_script="scripts/python/transform-fundglos-la-grants-to-flattened-shared-format.py"
fundglos_flattened_output_dir="pipeline/intermediate_data/fundglos-local-authority-grants"

mkdir -p "$fundglos_flattened_output_dir"

# This transforms to a CSV format which is compatible with flatten-tool. NOte: the python file is determining the location of the input file and output file which isn't flexible but it does work
# TODO: modify the python script to take in the source file as an argument, so that it can be set here
# TODO: modfify the python script to output its csvwriter to STDOUT so that we can control output direction here

python3 "$fundglos_transform_script"

# flatten-tool's CSV converter assumes that you have a directory of CSVs, which is silly. So instead of pointing it at the file we point it at the containing directory
# We also need to use jq to transform flatten-tool's output to JSONL to make it compatible with later stages in the pipeline

flatten-tool unflatten --input-format csv --root-list-path "grants" "$fundglos_flattened_output_dir" | jq -c '.grants[]' > "$mapped_data_dir/fundglos-la-grants.jsonl"
