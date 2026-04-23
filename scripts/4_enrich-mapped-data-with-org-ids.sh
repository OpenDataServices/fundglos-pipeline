#!/usr/bin/env bash

# This script takes the generated org-id lookup file and uses it to enrich the funding opportunities with org-id information where possible by performing a lookup
# It outputs some enriched data, which can then be further enriched by adding classifications to it as a final step.

org_id_lookup="./pipeline/intermediate_data/organisation-identifiers/org-id-lookup.jsonl"
org_id_jq_filter="./scripts/jq/add-org-ids-to-organisations.jq"
mapped_data_dir="./pipeline/intermediate_data/mapped-funding-data"
enriched_data_dir="./pipeline/intermediate_data/enriched-data"

mkdir -p "$enriched_data_dir"

echo "Enriching mapped data with org-ids discovered from the lookup (this will take a while)…"

cat "$mapped_data_dir"/*.jsonl | jq --compact-output --slurpfile identifiers "$org_id_lookup" --from-file "$org_id_jq_filter" > "$enriched_data_dir"/funding-with-org-ids.jsonl
