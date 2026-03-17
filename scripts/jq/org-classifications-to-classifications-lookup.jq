# This filter is designed to produce a JSON object for mapping org-ids against known classifications from various classification sources
# As input, it expects the result of running `csvjson` on a csv file which looks like this: "org_id","code","description","scheme","uri" where each row is a mapping of an org-id to a single code. It's advised that this csv file is the result of compiling various classificatin mappings together, to avoid having to wrangle multiple files.
# As output, it will produce an object like the following:
# {"org_id": "GB-CHC-12345", classifications: [{"value": "HE", "description": "Health", "scheme": "UK-CAT", "uri": "https://charityclassification.org.uk/data/tag_list/"}]}
# The output of this filter is designed to be loaded into another filter via --slurp-file, to provide a (relatively) rapid lookup for organisation classifications, avoiding the need for multiple passes of grants through various classification systems.

group_by(.org_id) | map({org_id: .[0].org_id, classifications: [.[] | {value: .code, description: .description, scheme: .scheme, uri: .uri}]})
