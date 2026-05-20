# This jq filter does final cleaning of the dataset by removing null properties and removing duplicate classification values

# Remove null properties
walk(if type == "object" then map_values(select(. != null)) else . end) 

# Remove duplicate classifications
| .recipient.classifications = (.recipient.classifications | unique)
| .funder.classifications = (.funder.classifications | unique)

# Prioritise GB-CHC identifiers if we have them
# This section is to promote any GB-CHC identifiers in the identifier or additionalIdentifiers array to the .id field to make the data easier to parse later. Not essential for analysis, but much nicer to marry organisations up across different datasets/publishers
# Goal is to catch cases where we have a GB-CHC identifier but .recipient.id is still gnarly, and freshen that up a bit
| if (
	(.recipient.id | startswith("GB-CHC") | not) and
	((.recipient.identifier.scheme == "GB-CHC") or (.recipient.additionalIdentifiers // [] | any(.scheme == "GB-CHC")))

     ) then
	# Get the first matching GB-CHC identifier and apply it to the .recipient.id field
	(
	  ([.recipient.identifier] + (.recipient.additionalIdentifiers // []))
	  | map(select(.scheme == "GB-CHC"))
	  | first
	  | .id 
	) as $new_id
	| .recipient.id = $new_id
	else
	  . # Leave intact if no match
end
