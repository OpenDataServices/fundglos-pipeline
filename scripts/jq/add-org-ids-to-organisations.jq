# This filter is designed to take input from the shared model of funding opportunities and then append organisation identifiers to those without them, via a lookup which has been generated previously
# It depends on running jq with `--slurpfile identifiers $identifiers_file` where $identifiers_file is a JSONL file and the result of creating the list of uppercase names mapped to organisation identifiers in the preparation stage.
# It will output a new list of funding opportunities with the appended data

# ===========================
# Helper Functions
# ===========================


# ===========================
# Main Pipeline
# ===========================

# Build the lookup table here so its available in context. There might be collisions, which will result in jq using the last value it encounters there

($identifiers | map({key: .name, value: .identifiers}) | from_entries) as $lookup |

. | 

if (.recipient.name != "Recipient Individual" and (.recipient.identifier == null or .recipient.identifier.scheme != "GB-CHC")) then
	# Lookup the org ID using the name (convert to uppercase to match the lookup file, remove any spaces)
	($lookup[.recipient.name | ascii_upcase | rtrimstr(" ")] // []) as $results |

	if $results != [] then
		# Ensure .recipient.additionalIdentifiers exists and is an array
		.recipient.additionalIdentifiers += $results
		# Ensure .recipient.additionalIdentifiers is an array before iterating
		| (.recipient.additionalIdentifiers // []) as $identifiers_list |
		
		# Set the identifier to use a GB-CHC number if present, or a GB-COH number if not, with a fallback of whatever other scheme it's using
		.recipient.identifier += (
				(first($identifiers_list[] | select(.scheme == "GB-CHC"))) //
				(first($identifiers_list[] | select(.scheme == "GB-COH"))) //
				$identifiers_list[0]
			       )
		
		# Set the .recipient.id field to be equal to our shiny new identifier, for convenience/cleanliness
		| .recipient.id = .recipient.identifier.identifier
	else
		# No match found, leave intact
		.
	end
  else 
  	. # Leave recipients with existing GB-CHC identifiers intact
  end
