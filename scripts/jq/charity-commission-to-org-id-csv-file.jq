# This script takes the charity commission JSON extract and transforms it into a CSV file for looking up org-ids via charity names.

(["name", "org_id"]), # Dummy entry to act as the CSV header layer
(.[] | [ .charity_name, "GB-CHC-\(.registered_charity_number)" ])
| @csv
