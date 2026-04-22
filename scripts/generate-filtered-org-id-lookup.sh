#!/usr/bin/env bash

# This script generates a lookup for organisation identifiers in a similar manner to the classification one
# First, the script extracts all of the recipient and funder names from the dataset, converts them to uppercase (to match the Charity Commission file), and then sorts them and removes any duplicates. THis ouput is saved as some intermediate data
# Second, it transforms the Charity Commission JSON data into a CSV file and uses csvgrep to filter it to only organisations which are in the data.
# Next, it uses the mapped data to find all of the organisations with known GB-CHC numbers and generates a CSV of these. This is so we eat our own dogfood and we may have some things that the charity commission lacks

# It relies on having fetched the charity commission data and also on having transformed data to map
# We write this output to disk here because csvgrep reserves STDIN for the actual csvdata that it's processing, and uses the --file flag to tell it which file to use for the matches.

mapped_funding_data_directory="./pipeline/intermediate_data/mapped-funding-data"
list_of_unique_org_names_destination_file="./pipeline/intermediate_data/organisation-identifiers/list-of-unique-org-names-in-dataset.txt"


# Get the list of unique org names. Use tr to convert to uppercase

cat "$mapped_funding_data_directory/"*.jsonl | jq -r '.recipient.name, .funder.name' | tr '[:lower:]' '[:upper:]' | sort --unique > "$list_of_unique_org_names_destination_file"

# Convert the Charity Commission data file to a CSV file to get our initial lookup

charity_commission_datafile="./pipeline/source_data/charity-commission/publicextract.charity.json"
charity_commission_conversion_filter="./scripts/jq/charity-commission-to-org-id-csv-file.jq"
charity_commission_org_id_csv_file="./pipeline/intermediate_data/organisation-identifiers/charity-commission-identifiers.csv"

jq --raw-output --from-file "$charity_commission_conversion_filter" "$charity_commission_datafile" | csvgrep --columns "name" --file "$list_of_unique_org_names_destination_file" > "$charity_commission_org_id_csv_file"

# Get a list of org-ids from our own dataset

mapped_data_org_id_extraction_filter="./scripts/jq/extract-org-ids-from-dataset.jq"
mapped_data_org_id_csv_file="./pipeline/intermediate_data/organisation-identifiers/mapped-data-identifiers.csv"

# Can't prepend a file in bash, so write the first line here. This is necessary because the charity commission lookup is all in uppercase, so all output from the following jq command will be transformed to uppercase, but the csv headings should be lowercase to enable stacking properly.
echo "name,org_id" > "$mapped_data_org_id_csv_file"

cat "$mapped_funding_data_directory"/*.jsonl | jq --raw-output --from-file "$mapped_data_org_id_extraction_filter" | tr '[:lower:]' '[:upper:]' | sort --unique >> "$mapped_data_org_id_csv_file" ## append, not overwrite
