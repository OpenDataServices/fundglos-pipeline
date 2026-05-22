# This filter is designed to produce a JSONL file for mapping names to org-ids from various sources, similar to how the classifications lookup works

# As input, it expects the result of running `csvjson` on a CSV file which looks like this "name", "org_id" where each row is a mapping of an organisation name to a single identifier.
# As output it will produce an object like the following:
# {"name": "$organisation_name", "identifiers": [{"id": "GB-EXAMPLE-123456", "scheme": "GB-EXAMPLE", "identifier": "123456"}]}
# This output is then designed to be loaded into another filter via --slurp-file to provide a (relatively) rapid lookup for organisation identifiers

group_by(.name) 
| map({name: .[0].name, identifiers: [.[] 
	| {id: .org_id, 
	   identifier: (.org_id | split("-")[-1]),
	   scheme: (.org_id | split("-")[0:2] | join("-"))
	   }
	]
       })

| .[]
