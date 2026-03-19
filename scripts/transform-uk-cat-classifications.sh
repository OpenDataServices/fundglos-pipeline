#!/usr/bin/env bash

# This script transforms the CSV files downloaded by `fetch-uk-cat-classifications.sh` into two intermediate CSV files which can then be using csvstack and transformed into an efficient lookup using jq.

# It depends on both: 1) the presence of the UK-CAT codelist and mapping files 2) the list of unique org-ids in the final dataset.

# This means that the classification pipeline should really be performed near-to-last, or at least after you've got all of the source data in the same format and have a list of unique org-ids in the dataset.


dataset_org_id_file="pipeline/intermediate_data/org-classifications/list-of-unique-org-ids-in-data.txt"

uk_cat_mapping_file="pipeline/source_data/uk-cat/charities_active-ukcat.csv"
uk_cat_definitions_file="pipeline/source_data/uk-cat/ukcat.csv"
uk_cat_sql_query="scripts/sql/convert-uk-cat-csv-to-shared-classification-format.sql"

icnptso_mapping_file="pipeline/source_data/uk-cat/charities_active-icnptso.csv"
icnptso_definitions_file="pipeline/source_data/uk-cat/icnptso.csv"
icnptso_sql_query="scripts/sql/convert-uk-cat-icnptso-csv-to-shared-classification-format.sql"

destination_dir="pipeline/intermediate_data/org-classifications"

mkdir -p "$destination_dir"


# Note: each of these pipelines starts off with a `csvgrep` which means that only rows matching org-ids in the source data are included. This is because we otherwise get an enormous 204,000 line monster of a file which slows down lookups a ridiculous amount.
# Personal tests showed that with 13,096 total lines (one funding opportunity per file) in the mapped source data, without csvgrep at the beginning of this pipeline the lookup for adding classifications to organisations took about 3.6 hours. With csvgrep, it took less than 30 seconds. Running `diff` against the results revealed that they were identical.

# For UK-CAT codes, We want the default inner join behaviour of csvjoin because otherwise we get blank rows, which are for codes which haven't been mapped to organisations.

csvgrep --columns "org_id" --file "$dataset_org_id_file" "$uk_cat_mapping_file"| csvjoin --columns "ukcat_code,Code" - "$uk_cat_definitions_file" | csvsql --query "$uk_cat_sql_query" > "$destination_dir/uk-cat-to-org-id-mappings-with-descriptions.csv"

# ICNTPSO Codes are organised taxonomically with groups and subgroups. In the file which maps org-ids to ICNPTSO codes, there's just one code per line. This has the following implications:
# 1) We need to do a full Left Outer Join to avoid omitting rows which don't map to either the category or subcategory codes
# 2) We need to do multiple passes to get descriptions for every code
# 3) We need to handle the fact that we will have two "Title" columns due to the multiple passes. This is handled specifically by the SQL query inside of $icnptso_sql_query

csvgrep --columns "org_id" --file "$dataset_org_id_file" "$icnptso_mapping_file" | csvjoin --left --columns "icnptso_code,Group" - "$icnptso_definitions_file" | csvcut --columns "org_id,icnptso_code,Title" | csvjoin --left --columns "icnptso_code,Sub-group" - "$icnptso_definitions_file" | csvsql --query "$icnptso_sql_query" > "$destination_dir/uk-cat-icnptso-mappings-with-descriptions.csv"
