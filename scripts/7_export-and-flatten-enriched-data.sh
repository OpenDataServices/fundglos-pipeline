#!/usr/bin/env bash
# This script is the final script in the pipeline and is designed to copy the final enriched data to the output directory and flatten it for export elsewhere.


mkdir -p "./pipeline/output_data"


# Final Stage of Filtering: tidy up
# ===========================================
# There's a bunch of nulls in the data which causes schema errors and potentially some analysis errors later.
# There's also cases where some recipients and funders are getting classifications applied to them twice; this shouldn't cause a problem with analysis but could lead to bulky data, so it's best to filter it out here.
# There are also cases where .recipient.id is nasty, but the .recipient object has a GB-CHC identifier object, so for these cases; the GB-CHC number is promoted to the value of .recipient.id to support cross-referencing between publishers using .id as a shorthand


enriched_data="./pipeline/intermediate_data/enriched-data/funding-with-org-ids-and-classifications.jsonl"
tidy_up_jq_filter="./scripts/jq/final-data-tidying.jq"
final_data="./pipeline/output_data/funding-data.jsonl"


echo "Tidying up data (removing nulls fields and duplicate classifications) and copying final dataset to the output_data directory"
jq --compact-output --from-file "$tidy_up_jq_filter" "$enriched_data" > "$final_data"


# Extract Useful Metrics and Info
# ==============================================
# Now we have some useful JSON-L, we can use it to extract some metrics and information

# Get a list of all organisations which don't have any GB-CHC numbers
orgs_without_charity_numbers_file="./pipeline/output_data/list-of-recipients-without-charity-numbers.csv"
orgs_without_charity_numbers_jq_filter="./scripts/jq/get-list-of-orgs-without-charity-numbers.jq"

echo "Extracting a list of all organisations without charity numbers, into $orgs_without_charity_numbers_file"

# Use > to write the header, overwriting from previous runs
echo "org_name" > "$orgs_without_charity_numbers_file"

jq --raw-output --from-file "$orgs_without_charity_numbers_jq_filter" "$final_data" | sort --unique >> "$orgs_without_charity_numbers_file"

# Write the header, using > to overwrite from previous runs

# Get a list of all organisations without classifications
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
