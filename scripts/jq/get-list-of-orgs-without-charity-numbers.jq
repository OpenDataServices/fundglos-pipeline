# This filter extracts a list of organisations from the dataset where there is no GB-CHC number in eitheer the .id, the .identifier.scheme, or the additionalIdentifiers.scheme


select( 
	# .recipient.id is required by the schema, so guaranteed to be there
	(.recipient.id | startswith("GB-CHC")| not) and 
	# If recipient.identifier.scheme is not present, then an empty tring matches the condition
	(.recipient.identifier.scheme // "" != "GB-CHC") and 
	# Catch cases where we have a recipient.identifier.id but no recipient.identifier.scheme
	(.recipient.identifier.id // "" | startswith("GB-CHC") | not) and 
	# If recipient.additionalIdentifiers is not present, then an empty array matches the condition
#	(.recipient.additionalIdentifiers[] // [] | all(.scheme != "GB-CHC"))
 	(.recipient.additionalIdentifiers | if . == null then [] else . end | all(.scheme // "" != "GB-CHC"))
)

| [(.recipient.name | ascii_upcase | rtrimstr(" "))]
| @csv
