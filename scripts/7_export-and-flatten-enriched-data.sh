#!/usr/bin/env bash
# This script is the final script in the pipeline and is designed to copy the final enriched data to the output directory and flatten it for export elsewhere.


mkdir -p "./pipeline/output_data"


# Final Stage of Filtering: remove nulls
# ===========================================
# There's a bunch of nulls in the data which causes schema errors and potentially some analysis errors later.


enriched_data="./pipeline/intermediate_data/enriched-data/funding-with-org-ids-and-classifications.jsonl"
final_data="./pipeline/output_data/funding-data.jsonl"
remove_null_jq_filter="./scripts/jq/remove-null-properties.jq"


echo "Tidying up data (removing null values) and copying enriched data (classifications + identiers) to the output_data directory…"
jq --compact-output --from-file "$remove_null_jq_filter" "$enriched_data" > "$final_data"



# Flatten Data
# ==============================================
# Flatten data so that the streamlit app can use it

# Flatten tool is silly and doesn't like JSONL, so we need to create a version of this which is in an array

echo "Preparing data for flattening…"

jq --slurp '{funding: .}' "$final_data" > "./pipeline/output_data/funding-data-in-array.json"

echo "Flattening data into Excel, LibreOffice, and CSV files (this can take a while for larger datasets)…"

cd "./pipeline/output_data" # This is a dirty hack, but flatten-tool's interface is a bit meh and this is faster. TODO

flatten-tool flatten --main-sheet-name "funding_opportunities" --root-list-path "funding" --output-format all funding-data-in-array.json
