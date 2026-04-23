# This script takes the charity commission JSON extract and transforms it into a CSV file for looking up org-ids via charity names.

(["name", "org_id"]), # Dummy entry to act as the CSV header layer
(.[] | select(.charity_registration_status != "Removed") | # Add a filter to catch removed registrations. Charity Commission appear to re-use identifiers, so we end up with lots of duplicate names but different org-ids here for irrelevant orgs. We might end up missing a few org-ids we want if a grant was made to an org which is now defunct, but this is a reasonable trade-off for now and there are other sources of org-ids
	[ .charity_name, "GB-CHC-\(.registered_charity_number)" ] 
) | @csv
