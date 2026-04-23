#!/usr/bin/env bash

# This script is one of the final scripts in the pipeline. It will take the data which has been enriched with org-ids and enrich it further with classifications. This will take some time!
# There may still be some recepients without classifications at the end of this, this is because the identifier they use is not in the classification lookup. This could be because either nobody has mapped them yet, or that the identifier is not a unique or standardised identifier scheme present in the lookup.

classifications_lookup="pipeline/intermediate_data/org-classifications/classifications-lookup.jsonl"
filter_file="scripts/jq/add-classifications-to-organisations.jq"

funding_data_with_org_ids="pipeline/intermediate_data/enriched-data/funding-with-org-ids.jsonl"
funding_data_with_org_ids_and_classifications="pipeline/intermediate_data/enriched-data/funding-with-org-ids-and-classifications.jsonl"


echo "Enriching data with classifications (Make a brew, this will take a fairly long time!)…"

jq --compact-output --slurpfile classifications "$classifications_lookup" --from-file "$filter_file" "$funding_data_with_org_ids" > "$funding_data_with_org_ids_and_classifications"
