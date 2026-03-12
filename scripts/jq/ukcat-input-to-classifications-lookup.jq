# This filter is designed to produce a JSON object for mapping org-ids against known classifications from UK-CAT
# As input, it assumes output from running csvjoin --columns ukcat_code,Code charities_active-ukcat.csv ukcat.csv | csvcut --columns org_id,ukcat_code,tag | csvjson
# As output, it will produce an object like the following:
# {"org_id": "GB-CHC-12345", classifications: [{"value": "HE", "description": "Health", "scheme": "UK-CAT", "uri": "https://charityclassification.org.uk/data/tag_list/"}]}

# The URI is manually set to the UK-CAT list of tags documentation page.

group_by(.org_id) | map({org_id: .[0].org_id, classifications: [.[] | {value: .ukcat_code, description: .tag, scheme: "UK-CAT", uri: "https://charityclassification.org.uk/data/tag_list/"}]})
