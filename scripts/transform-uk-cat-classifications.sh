#!/usr/bin/env bash

# This script transforms the CSV files downloaded by `fetch-uk-cat-classifications.sh` into a JSON object which serves as an efficient lookup for classifications for organisations. This can then be used in the pipeline to rapidly append classifications to organisations.

# It depends on the presence of the four files in `pipeline/source_data/uk-cat`. If these don't exist yet, run `fetch-uk-cat-classifications.sh` before this.

destination_dir="pipeline/intermediate_data"
source_data_dir="pipeline/source_data/uk-cat"
filter_file="scripts/jq/ukcat-input-to-classifications-lookup.jq"

mkdir -p "$destination_dir"


# For each classification, we want both the code and the human-readable title. So join the classification codelist onto the file which maps it to org-ids. We want the default inner join behaviour because otherwise we get blank rows, which are for codes which haven't been mapped to organisations.
# Then we want to massage that into a nicer shape by cutting out a lot of the columns we don't need, and then sending it on to csvjson where it can be transformed into the shape we need via jq

# Note: we're currently omitting the icnptso codes provided by UK-CAT. This is because it's unclear how important they are to our priorities at this time and it might be a faff to create a clean pipeline to ensure that all the classifications get added properly in the lookup

csvjoin --columns ukcat_code,Code "$source_data_dir/charities_active-ukcat.csv" "$source_data_dir/ukcat.csv" | csvcut --columns org_id,ukcat_code,tag | csvjson | jq -c --from-file "$filter_file" > "$destination_dir/uk-cat-classifications.json"
