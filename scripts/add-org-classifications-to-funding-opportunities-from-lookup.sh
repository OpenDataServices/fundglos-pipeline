#!/usr/bin/env bash

# This script is one of the final scripts in the pipeline. It takes all of the standardised funding data from the different sources which are generated in previous scripts, and runs it through a jq filter which adds organisation classifications based on the lookup generated from the classification pipeline
# It is not very fast! Lookups are slow. Running this with lots of funding opportunities will take a long time. There may be efficiency tweaks we can make to different parts of the pipeline such as the jq filter or the org-classifications filter, but this is where we get the ability to disambiguate between different types of organisation receiving funding.
# There may still be some recepients without classifications at the end of this, this is because the identifier they use is not in the classification lookup. This could be because either nobody has mapped them yet, or that the identifier is not a unique or standardised identifier scheme present in the lookup.

data_dir="pipeline/intermediate_data/mapped-funding-data"
classifications_lookup="pipeline/intermediate_data/org-classifications/classifications-lookup.jsonl"
filter_file="scripts/jq/add-classifications-to-organisations.jq"

destination_dir="pipeline/output_data"

mkdir -p "$destination_dir"

# Everything inside $data_dir should be standardised and mapped and in JSONL, so should be safe to concatanate and feed to the filter.
cat $data_dir/*.jsonl | jq --compact-output --slurpfile classifications "$classifications_lookup" --from-file "$filter_file" > "$destination_dir/funding-data-with-org-classifications.jsonl"
