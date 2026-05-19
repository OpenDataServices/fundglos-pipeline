# This jq filter does final cleaning of the dataset by removing null properties and removing duplicate classification values

# Remove null properties
walk(if type == "object" then map_values(select(. != null)) else . end) 

# Remove duplicate classifications
| .recipient.classifications = (.recipient.classifications | unique)
| .funder.classifications = (.funder.classifications | unique)
