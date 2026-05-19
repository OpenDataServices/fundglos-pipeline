# This jq filter is designed to be run at the end of the pipeline to support extracting a list of all the unique org-name and org-id combos in the dataset, to support these being used for appending manually
# It is designed to be run with `jq --raw-output` for outputting a CSV file
# It doesn't do any sorting or filtering to remove duplicates; pass the output of this filter to `sort --unique`
# Note: there is no dummy entry to act as the CSV header here, due to needing to pass it to `sort --unique`. You'll need to create this via the calling script

([.recipient.name, .recipient.identifier?.id], [.funder.name, .funder.identifier?.id]) | @csv

