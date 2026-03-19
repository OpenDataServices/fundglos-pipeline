-- This query is designed to be used with `csvsql` as part of the transform pipeline which turns the UK-CAT files into a CSV mapping org-ids to UK-CAT classifications, with some additional fixtures to add a uri and a scheme

SELECT org_id, ukcat_code AS code, tag AS description, 'UK-CAT' AS scheme, 'https://charityclassification.org.uk/data/tag_list/' AS uri FROM stdin;
