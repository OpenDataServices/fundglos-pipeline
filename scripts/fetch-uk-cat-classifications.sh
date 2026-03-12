#!/usr/bin/env bash

# This script retrieves the charity classification data from UK-CAT's github repository and transforms it to a JSONL file which provides efficient lookup of charity classifications.

# https://github.com/charity-classification/ukcat/

mkdir -p ../source_data/uk-cat

curl https://github.com/charity-classification/ukcat/raw/refs/heads/main/data/charities_active-ukcat.csv > ../source_data/uk-cat/charities-active-ukcat.csv
