#!/usr/bin/env bash

# This script fetches the source data required for the fundglos pipeline.
# It is designed to be run first
# Originally, it was separate scripts but this became unwieldy and hard to conceptualise where any part of the pipeline was at


cc_dir="pipeline/source_data/charity-commission"
coh_dir="pipeline/source_data/companies-house"
ukcat_dir="pipeline/source_data/uk-cat"
fundglos_dir="pipeline/source_data/fundglos"
threesixty_dir="pipeline/source_data/threesixtygiving-datastore"

mkdir -p $cc_dir $ukcat_dir $fundglos_dir $threesixty_dir $coh_dir


# Fetch Charity Commission Data
# ==========================
# https://register-of-charities.charitycommission.gov.uk/en/register/full-register-download

echo "Fetching Charity Commission datafile of charity data…"

# The Charity commission file is zipped which is very unhelpful, but it should be OK to unzip it here on most systems

curl "https://ccewuksprdoneregsadata1.blob.core.windows.net/data/json/publicextract.charity.zip" > "$cc_dir/gb-chc-data.zip"

unzip -p "$cc_dir/gb-chc-data.zip" > "$cc_dir/gb-chc-identifiers.json"


# Fetch Companies House Data
# ==============================
# https://download.companieshouse.gov.uk/en_output.html

# TODO: scrape the actual web page to find the latest download link.
# The companies house data is really unhelpful, because the latest download is not aliased as "latest", meaning you need the exact url.
# At the moment, we've just used the 2026-05-01 link, for expedience

echo "Fetching Companies House datafile of Companies data…"

curl "https://download.companieshouse.gov.uk/BasicCompanyDataAsOneFile-2026-05-01.zip" > "$coh_dir/gb-coh-data.zip"

unzip -p "$coh_dir/gb-coh-data.zip" > "$coh_dir/gb-coh-identifiers.csv"


# Fetch UK-CAT data
# ==========================
# https://github.com/charity-classification/ukcat/

# There are four files we are interested in: two codelists which are UK-CAT and ICNPTSO, and two mappings from UK Org-Ids to these codelists.
# TODO: bring in the inactive charity lists because there might be org-ids in there that we're missing classifications for by just using the active charity lists

echo "Fetching UK-CAT classification files…"

curl "https://raw.githubusercontent.com/charity-classification/ukcat/refs/heads/main/data/ukcat.csv" > "$ukcat_dir/ukcat.csv"

curl "https://raw.githubusercontent.com/charity-classification/ukcat/refs/heads/main/data/charities_active-ukcat.csv" > "$ukcat_dir/charities_active-ukcat.csv"

curl "https://raw.githubusercontent.com/charity-classification/ukcat/refs/heads/main/data/charities_active-icnptso.csv" > "$ukcat_dir/charities_active-icnptso.csv"

curl "https://raw.githubusercontent.com/charity-classification/ukcat/refs/heads/main/data/icnptso.csv" > "$ukcat_dir/icnptso.csv"

# Fetch Fundglos data
# ================================
# Data that's provided by us for the fundglos project

echo "Fetching manually produced grant data for the FundGlos project…"

fundglos_la_data_url="https://docs.google.com/spreadsheets/d/1L3T2weYA6tK7eaqEKaPstEBtoB3F6X8sLRZTgo2vigw/export?format=xlsx"

curl -L "$fundglos_la_data_url" -o "$fundglos_dir/local-authority-grants.xlsx"

fundglos_gcf_summerfield_url="https://docs.google.com/spreadsheets/d/16lCoPYNAVuor3efXosbgYr9wQ-M2I0AOgpa0jvtdyWo/export?format=csv"

curl -L "$fundglos_gcf_summerfield_url" -o "$fundglos_dir/gcf-summerfield-grants.csv"


# Format for CSV exports is /export?format=csv&gid={gid from URL of tab}
fundglos_org_id_mapping_url="https://docs.google.com/spreadsheets/d/1fw04HH31VayMgFlJPPzjAzwLlBfKuqrWm1goEfhsWzI/export?format=csv&gid=977674719"

curl -L "$fundglos_org_id_mapping_url" -o "$fundglos_dir/fundglos-org-id-mapping.csv"

fundglos_classification_mapping_url="https://docs.google.com/spreadsheets/d/1fw04HH31VayMgFlJPPzjAzwLlBfKuqrWm1goEfhsWzI/export?format=csv&gid=38613526"

curl -L "$fundglos_classification_mapping_url" -o "$fundglos_dir/fundglos-org-id-uk-cat-mappings.csv"

# Fetch Threesixty Giving Datastore data
# ===========================================
# 

echo "Fetching 360Giving Datastore data (this will take a long time)…"

datastore_query_file="scripts/sql/360g-datastore-extract-grants-and-additional-data-with-location-in-gloucestershire.sql"
#datastore_query_file="scripts/sql/test-with-limited-grants.sql" # uncomment this line to only use a subset of grants

# Set --tuples-only and --no-align to avoid polluting the output file with cruft and we get beautiful JSONL
psql --file="$datastore_query_file" --output="$threesixty_dir/datastore-grants.jsonl" --tuples-only --no-align
