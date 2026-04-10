#!/usr/bin/env bash

# This script fetches the large Charity Commission data file in JSON format so that it can be used elsewhere for different lookups


destination_dir="pipeline/source_data/charity-commission"

mkdir -p $destination_dir

# The Charity commission file is zipped which is very unhelpful, but it should be OK to unzip it here on most systems

curl "https://ccewuksprdoneregsadata1.blob.core.windows.net/data/json/publicextract.charity.zip" > "$destination_dir/gb-chc-data.zip"

unzip "$destination_dir/gb-chc-data.zip" -d "$destination_dir"
