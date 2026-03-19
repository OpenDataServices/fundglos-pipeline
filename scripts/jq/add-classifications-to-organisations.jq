# This filter is designed to take input from the shared model of funding opportunities, and append classification objects to the organisations in the .funder and .recipient keys based on a lookup to the organiation identifier
# It depends on running jq with `--slurpfile classifications $classifications_file` where $classifications_file is the result of creating the list of org-ids mapped to classifications in the preparation stage.
# It will output a new list of funding opportunities with the appended data

# ===========================
# Helper Functions
# ===========================

def get_classifications($org; $lookup):
# This function takes an organisation object and then creates an array of its identifiers to perform lookups inside $lookup for classifications, then merges the array and removes duplicates
# For data mapped from 360Giving, recipient individuals don't have an identifier field or additionalIdentifiers array, so `?` accounts for possible nulls
	[$org.id] +
	[$org.identifier.id?] +
	[$org.additionalIdentifiers[]?.id]
	| map(select(. != null)) # Remove any potentially null identifiers
	| map($lookup[.] // []) # Returns an empty array if no match found
	| add
#	| unique # Remove duplicate identifiers. This is costly processing.
;



# ===========================
# Main pipeline
# ===========================

# We need to build the lookup table here so that it's available in the context for the helper function

($classifications | map({key: .org_id, value: .classifications}) | from_entries) as $lookup

# The main pipeline simply conists of running the get_classifications() function across each the recipient and funding orgs to append classifications and then outputting the result.

| .recipient.classifications += get_classifications(.recipient; $lookup)
| .funder.classifications += get_classifications(.funder; $lookup)

# Original query; limited to looking at .id
#($classifications | map({key: .org_id, value: .classifications}) | from_entries) as $lookup 
#| .recipient.classifications += ($lookup[.recipient.id] // []) 
#| .funder.classifications += ($lookup[.funder.id] // [])
