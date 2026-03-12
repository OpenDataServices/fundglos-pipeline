# This filter is designed to take input from the shared model of funding opportunities, and append classification objects to the organisations in the .funder and .recipient keys based on a lookup to the organiation identifier
# It depends on running jq with `--slurpfile classifications $classifications_file` where $classifications_file is the result of creating the list of org-ids mapped to classifications in the preparation stage.
# It will output a new list of funding opportunities with the appended data

# TODO: it currently works just on organisation.id, but could possibly be modified to work on a match from each identifier stored in the identifier array

($classifications | map({key: .org_id, value: .classifications})| from_entries) as $lookup | .recipient.classifications += ($lookup[.recipient.id] // []) | .funder.classifications += ($lookup[.funder.id] // [])
