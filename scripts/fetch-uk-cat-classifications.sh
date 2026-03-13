#!/usr/bin/env bash

# This script retrieves the charity classification data from UK-CAT's github repository so that they can later be transformed to an efficient classification lookup for organisations

# https://github.com/charity-classification/ukcat/

destination_dir="pipeline/source_data/uk-cat"

mkdir -p $destination_dir


# There are four files we are interested in: two codelists which are UK-CAT and ICNPTSO, and two mappings from UK Org-Ids to these codelists.

curl "https://raw.githubusercontent.com/charity-classification/ukcat/refs/heads/main/data/ukcat.csv" > "$destination_dir/ukcat.csv"

curl "https://raw.githubusercontent.com/charity-classification/ukcat/refs/heads/main/data/charities_active-ukcat.csv" > "$destination_dir/charities_active-ukcat.csv"

curl "https://raw.githubusercontent.com/charity-classification/ukcat/refs/heads/main/data/charities_active-icnptso.csv" > "$destination_dir/charities_active-icnptso.csv"

curl "https://raw.githubusercontent.com/charity-classification/ukcat/refs/heads/main/data/icnptso.csv" > "$destination_dir/icnptso.csv"
