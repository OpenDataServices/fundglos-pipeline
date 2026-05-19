#!/usr/bin/env bash
# This script is the final script in the pipeline and is designed to copy the final enriched data to the output directory and flatten it for export elsewhere.


mkdir -p "./pipeline/output_data"


# Final Stage of Filtering: remove nulls
# ===========================================
# There's a bunch of nulls in the data which causes schema errors and potentially some analysis errors later.
# There's also cases where some recipients and funders are getting classifications applied to them twice; this shouldn't cause a problem with analysis but could lead to bulky data, so it's best to filter it out here.


enriched_data="./pipeline/intermediate_data/enriched-data/funding-with-org-ids-and-classifications.jsonl"
tidy_up_jq_filter="./scripts/jq/remove-null-properties-and-duplicate-classifications.jq"
final_data="./pipeline/output_data/funding-data.jsonl"


echo "Tidying up data (removing nulls fields and duplicate classifications) and copying final dataset to the output_data directory"
jq --compact-output --from-file "$tidy_up_jq_filter" "$enriched_data" > "$final_data"


# Extract Useful Metrics and Info
# ==============================================
# Now we have some useful JSON-L, we can use it to extract some metrics and information

# Getting a list of organisations with their identifiers

final_list_of_orgs_file="./pipeline/output_data/list-of-orgs-with-identifiers.csv"
final_list_of_orgs_jq_filter="./scripts/jq/get-list-of-orgs-with-identifiers.jq"

echo "Extracting a list of all funders and recipients in the data with their identifiers to $final_list_of_orgs_file"

# Write the header, using > to overwrite from previous runs
echo "org_name,org_id" > "$final_list_of_orgs_file"

# Append the file with a filtered, sorted, list of organisations with their ids to spot empty ones
jq --raw-output --from-file "$final_list_of_orgs_jq_filter" "$final_data" | sort --unique >> "$final_list_of_orgs_file"


# TODO: get a list of all organisations without classifications
orgs_without_classifications_file="./pipeline/output_data/list-of-orgs-without-classifications.csv"
orgs_without_classifications_jq_filter="./scripts/jq/get-list-of-all-organisations-without-classifications.jq"

echo "Extracting a list of all organisations without classifications, into $orgs_without_classifications_file"

# Same deal as before, write the header and then append the result of the filter
echo "org_name,org_id" > "$orgs_without_classifications_file"

jq --raw-output --from-file "$orgs_without_classifications_jq_filter" "$final_data" | sort --unique >> "$orgs_without_classifications_file"


# Flatten Data
# ==============================================
# Flatten data so that the streamlit app can use it

# Flatten tool is silly and doesn't like JSONL, so we need to create a version of this which is in an array

echo "Preparing data for flattening…"

jq --slurp '{funding: .}' "$final_data" > "./pipeline/output_data/funding-data-in-array.json"

echo "Flattening data into Excel, LibreOffice, and CSV files (this can take a while for larger datasets)…"

cd "./pipeline/output_data" # This is a dirty hack, but flatten-tool's interface is a bit meh and this is faster. TODO

flatten-tool flatten --main-sheet-name "funding_opportunities" --root-list-path "funding" --output-format all funding-data-in-array.json
