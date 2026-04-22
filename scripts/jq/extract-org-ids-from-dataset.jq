# This jq filter takes the mapped data as input, and extracts the names of organisations and their GB-CHC identifier where it is present and outputs it as a csv file
# The output of this filter should be processed further to make it compatible with the charity commmision data, namely by making the name column uppercase.
# For this reason, there is no dummy entry to create the CSV header in this filter. This is done elsewhere in bash

select(.recipient.identifier.scheme == "GB-CHC") | [.recipient.name, .recipient.identifier.id] | @csv
