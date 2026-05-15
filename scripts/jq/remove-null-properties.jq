# This jq filter removes any null properties from an item to support consistency.

walk(if type == "object" then map_values(select(. != null)) else . end) 
