#!/usr/bin/env bash

# This script takes the xlsx file downloaded as part of fetch-fundglos-local-authority-grant-data.sh and steps it through a transform process to end up with JSONL in the shared format which can then be combined with other sources of funding data to be enriched

# TODO: modify the python script to take in the source file as an argument, so that it can be set here
# TODO: modfify the python script to output its csvwriter to STDOUT so that we can control output direction here

transform_script="scripts/python/transform-fundglos-la-grants-to-flattened-shared-format.py"
flattened_output_dir="pipeline/intermediate_data/fundglos-local-authority-grants"
jsonl_output_dir="pipeline/intermediate_data/mapped-funding-data"

mkdir -p "$flattened_output_dir"
mkdir -p "$jsonl_output_dir"

# This transforms to a CSV format which is compatible with flatten-tool
python3 "$transform_script"

# flatten-tool's CSV converter assumes that you have a directory of CSVs, which is silly. So instead of pointing it at the file we point it at the containing directory
flatten-tool unflatten --input-format csv --root-list-path "grants" "$flattened_output_dir" | jq -c '.grants[]' >> "$jsonl_output_dir/fundglos-la-grants.jsonl"
