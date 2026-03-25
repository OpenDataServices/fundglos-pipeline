#!/usr/bin/env bash

# This script retrieves the grants that were scraped and cleaned as part of the Fund Glos projects.
# They are stored in a publically-accessible Google sheet.
# This script downloads them as-is, and then they get converted via some Python Scripts later.

gsheets_url="https://docs.google.com/spreadsheets/d/1L3T2weYA6tK7eaqEKaPstEBtoB3F6X8sLRZTgo2vigw/export?format=xlsx"

download_destination="pipeline/source_data/fundglos"

mkdir -p "$download_destination"

curl -L "$gsheets_url" -o local-authority-grants.xlsx
