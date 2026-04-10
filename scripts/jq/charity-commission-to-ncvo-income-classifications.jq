# This jq filter takes input from the Charity commission file and generates a CSV file representing the NCVO income classifications for that org-id mapping

(["org_id","code","description","scheme","uri"]), # Add this to simulate a header row in the CSV output
(
.[] | 
select(.latest_income != null) |
["GB-CHC-\(.registered_charity_number)", 
	( if .latest_income < 10000 then "Micro"
	  elif .latest_income >= 10000 and .latest_income < 100000 then "Small"
	  elif .latest_income >= 100000 and .latest_income < 1000000 then "Medium"
	  elif .latest_income >= 1000000 and .latest_income < 10000000 then "Large"
	  elif .latest_income >= 10000000 and .latest_income < 100000000 then "Major"
	  elif .latest_income >= 100000000 then "Super-major"
	  else "Unknown"
	  end ),
"NCVO Income Size",
"https://www.ncvo.org.uk/news-and-insights/news-index/uk-civil-society-almanac-2024/about/definitions/#income-bands"]
) |
@csv
