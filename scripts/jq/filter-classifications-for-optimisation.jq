# This script filters the JSONL file produced by transforming the org-id to classifications mapping and produces an output which includes only mapping for org-ids which are in the dataset of mapped funding.
# It relies on using --rawfile with the list of org ids in the data

# Convert IDs array to a set for O(1) lookups

 # Split the raw content by newlines and filter out empty lines
#($ids | split("\n") | map(select(. != ""))) as $id_list
#| select($id_list[.org_id])

# This script filters the JSONL file produced by transforming the org-id to classifications mapping 
# and produces an output which includes only mapping for org-ids which are in the dataset of mapped funding.
# It relies on using --rawfile with the list of org ids in the data

# Split the raw content by newlines and filter out empty lines
($ids | split("\n") | map(select(. != ""))) as $id_list

# Convert IDs array to a set for O(1) lookups
| ($id_list | map({(.): true}) | add) as $lookup_set

# Select only records whose org_id is in the set
| select($lookup_set[.org_id])


