#!/usr/bin/env bash
# This script is the final script in the pipeline and is designed to copy the final enriched data to the output directory and flatten it for export elsewhere.


mkdir -p "./pipeline/output_data"

# Copy data
# ===========================================
# Copy the enriched data to the output directory

enriched_data="./pipeline/intermediate_data/enriched-data/funding-with-org-ids-and-classifications.jsonl"
final_data="./pipeline/output_data/funding-data.jsonl"

echo "Copying final enriched data (with org-ids and classifications) to the output_data directory"
cp "$enriched_data" "$final_data"


# Flatten Data
# ==============================================
# Flatten data so that the streamlit app can use it

# Flatten tool is silly and doesn't like JSONL, so we need to create a version of this which is in an array

echo "Preparing data for flattening (this can take a while)…"

funding_data_in_array="./pipeline/output_data/funding-data-in-array-for-flattening.json"
jq --slurpfile funding "$final_data" '{main: $funding}' > "$funding_data_in_array"
