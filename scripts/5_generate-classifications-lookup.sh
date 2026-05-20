#!/usr/bin/env bash
# This script generates the classifications lookup file which is used to enrich the funding data with organisation classifications based on their org-ids

# This script is dependant on having already enriched the dataset with organisation identifiers, as it requires these to filter the classifications in source datasets



org_classifications_dir="./pipeline/intermediate_data/org-classifications/"
dataset_org_id_file="./pipeline/intermediate_data/org-classifications/list-of-unique-org-ids-in-data.txt"

mkdir -p "$org_classifications_dir"


# Generating the list of org-ids from the dataset
# =================================================
# This is required to start filtering for org-ids

funding_with_org_ids="./pipeline/intermediate_data/enriched-data/funding-with-org-ids.jsonl"
org_id_jq_filter="scripts/jq/get-org-ids-from-dataset.jq"

echo "Generating a list of unique org-ids in the dataset…"

jq -r --from-file "$org_id_jq_filter" $funding_with_org_ids | sort --unique | grep -v '^null$' > "$dataset_org_id_file"

# Getting Classifications from the UK-CAT source files
# =====================================================
# Here we take the UK-CAT source files and generate a CSV of classifications from them

# Note: each of these pipelines starts off with a `csvgrep` which means that only rows matching org-ids in the source data are included. This is because we otherwise get an enormous 204,000 line monster of a file which slows down lookups a ridiculous amount.
# Personal tests showed that with 13,096 total lines (one funding opportunity per file) in the mapped source data, without csvgrep at the beginning of this pipeline the lookup for adding classifications to organisations took about 3.6 hours. With csvgrep, it took less than 30 seconds. Running `diff` against the results revealed that they were identical.

echo "Transforming UK-CAT and ICNPTSO codes into lookup tables…"

uk_cat_mapping_file="pipeline/source_data/uk-cat/charities_active-ukcat.csv"
uk_cat_definitions_file="pipeline/source_data/uk-cat/ukcat.csv"
uk_cat_sql_query="scripts/sql/convert-uk-cat-csv-to-shared-classification-format.sql"

icnptso_mapping_file="pipeline/source_data/uk-cat/charities_active-icnptso.csv"
icnptso_definitions_file="pipeline/source_data/uk-cat/icnptso.csv"
icnptso_sql_query="scripts/sql/convert-uk-cat-icnptso-csv-to-shared-classification-format.sql"

# For UK-CAT codes, We want the default inner join behaviour of csvjoin because otherwise we get blank rows, which are for codes which haven't been mapped to organisations.

csvgrep --columns "org_id" --file "$dataset_org_id_file" "$uk_cat_mapping_file"| csvjoin --columns "ukcat_code,Code" - "$uk_cat_definitions_file" | csvsql --query "$uk_cat_sql_query" > "$org_classifications_dir/uk-cat-to-org-id-mappings-with-descriptions.csv"

# ICNTPSO Codes are organised taxonomically with groups and subgroups. In the file which maps org-ids to ICNPTSO codes, there's just one code per line. This has the following implications:
# 1) We need to do a full Left Outer Join to avoid omitting rows which don't map to either the category or subcategory codes
# 2) We need to do multiple passes to get descriptions for every code
# 3) We need to handle the fact that we will have two "Title" columns due to the multiple passes. This is handled specifically by the SQL query inside of $icnptso_sql_query

csvgrep --columns "org_id" --file "$dataset_org_id_file" "$icnptso_mapping_file" | csvjoin --left --columns "icnptso_code,Group" - "$icnptso_definitions_file" | csvcut --columns "org_id,icnptso_code,Title" | csvjoin --left --columns "icnptso_code,Sub-group" - "$icnptso_definitions_file" | csvsql --query "$icnptso_sql_query" > "$org_classifications_dir/uk-cat-icnptso-mappings-with-descriptions.csv"

# Getting NCVO Income Classifications from the Charity Commission file
# ======================================================================

charity_commission_source_data="pipeline/source_data/charity-commission/publicextract.charity.json"
charity_commission_jq_filter_file="scripts/jq/charity-commission-to-ncvo-income-classifications.jq"

# The jq filter wrangles the charity commission data into the correct shape of CSV, and then we use csvgrep to filter it for org-ids we have. Technically it's possible to do the filtering stage with jq but the syntax is messier and it represents another lookup which might be expensive.

# The manpage of csvgrep claims that if the input file is omitted it will accept input from STDIN. Without csvgrep this output file totals 252,968 lines…

echo "Generating NCVO Income Band Classification lookup table from Charity Commission data…"

jq --raw-output --from-file "$charity_commission_jq_filter_file" "$charity_commission_source_data" | csvgrep --columns "org_id" --file "$dataset_org_id_file" > "$org_classifications_dir/ncvo-income-bands.csv"

# If you have any more classification sources to add, add them here!

# Using the Fundglos Classifications file (which are actually UK-CAT)
# ===================================================================

fundglos_uk_cat_source_data="./pipeline/source_data/fundglos/fundglos-org-id-uk-cat-mappings.csv"

echo "Copying Fundglos' handcrafted classifications table"

cp "$fundglos_uk_cat_source_data" "$org_classifications_dir/fundglos-uk-cat-mappings.csv"

# Final Stage
# ==========================================
# Take all the .csv files generated by previous stages and compile them all into a large JSONL lookup

generate_jsonl_lookup_filter_file="scripts/jq/org-classifications-to-classifications-lookup.jq"

echo "Generating JSONL lookup table of org-ids to classifications"

csvstack "$org_classifications_dir"/*.csv | csvjson | jq --compact-output --from-file "$generate_jsonl_lookup_filter_file" > "$org_classifications_dir/classifications-lookup.jsonl"
