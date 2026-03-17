#!/usr/bin/env bash

# This script transforms the CSV files downloaded by `fetch-uk-cat-classifications.sh` into two intermediate CSV files which can then be using csvstack and transformed into an efficient lookup using jq.

# It depends on the presence of the four files in `pipeline/source_data/uk-cat`. If these don't exist yet, run `fetch-uk-cat-classifications.sh` before this.

destination_dir="pipeline/intermediate_data/org-classifications"
source_data_dir="pipeline/source_data/uk-cat"
filter_file="scripts/jq/ukcat-input-to-classifications-lookup.jq"

mkdir -p "$destination_dir"

# For UK-CAT codes, We want the default inner join behaviour of csvjoin because otherwise we get blank rows, which are for codes which haven't been mapped to organisations.

csvjoin --columns "ukcat_code,Code" "$source_data_dir/charities_active-ukcat.csv" "$source_data_dir/ukcat.csv" | csvsql --query "SELECT org_id, ukcat_code AS code, tag AS description, 'UK-CAT' AS scheme, 'https://charityclassification.org.uk/data/tag_list/' AS uri FROM stdin;" > "$destination_dir/uk-cat-to-org-id-mappings-with-descriptions.csv"

# ICNTPSO Codes are organised taxonomically with groups and subgroups. In the file which maps org-ids to ICNPTSO codes, there's just one code per line. This has the following implications:
# 1) We need to do a full Left Outer Join to avoid omitting rows which don't map to either the category or subcategory codes
# 2) We need to do multiple passes to get descriptions for every code

csvjoin --left --columns icnptso_code,Group "$source_data_dir/charities_active-icnptso.csv" "$source_data_dir/icnptso.csv" | csvcut --columns "org_id,icnptso_code,Title" | csvjoin --left --columns "icnptso_code,Sub-group" - "$source_data_dir/icnptso.csv" | csvsql --query "SELECT org_id, icnptso_code AS code, COALESCE(Title, Title2) as description,'ICNTPSO' as scheme, 'https://unstats.un.org/unsd/publication/seriesf/seriesf_91e.pdf' AS uri FROM stdin;" > "$destination_dir/uk-cat-icnptso-mappings-with-descriptions.csv"
