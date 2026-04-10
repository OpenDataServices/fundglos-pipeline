#!/usr/bin/env bash

# This script will take the JSON file from the Charity Commission and it will generate a CSV file to be used when generating the classifications lookup.

# It relies on the following:
#
# 1) you have run the fetch for getting the charity commission JSON data
# 2) you have generated a list of unique org-ids in the funding dataset.

# The second stage is important because these org-ids will act as a filter to reduce the size of the CSV file produced at the end, and thus ensure that enriching the data with org classifications later is as  efficient as possible.

dataset_org_id_file="pipeline/intermediate_data/org-classifications/list-of-unique-org-ids-in-data.txt"
charity_commission_source_data="pipeline/source_data/charity-commission/publicextract.charity.json"
output_file="pipeline/intermediate_data/org-classifications/ncvo-income-bands.csv"

jq_filter_file="scripts/jq/charity-commission-to-ncvo-income-classifications.jq"

# The jq filter wrangles the charity commission data into the correct shape of CSV, and then we use csvgrep to filter it for org-ids we have. Technically it's possible to do the filtering stage with jq but the syntax is messier and it represents another lookup which might be expensive.

# The manpage of csvgrep claims that if the input file is omitted it will accept input from STDIN. Without csvgrep this output file totals 252,968 lines…

jq --raw-output --from-file "$jq_filter_file" "$charity_commission_source_data" | csvgrep --columns "org_id" --file "$dataset_org_id_file" > "$output_file"
