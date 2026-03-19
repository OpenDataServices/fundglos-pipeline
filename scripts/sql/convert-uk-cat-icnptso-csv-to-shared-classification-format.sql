-- This query is designed to work with csvsql, and is part of the transform pipeline transforming the ICNPTSO code mappings provided by UK-CAT into a shared classification format. It produces a CSV mapping org-ids to ICNPTSO codes

-- COALESCE is used because we end up with two "Title" fields in the csv pipeline, resulting from multiple passes doing Left Joins on the source codelist for each "Group" and "Sub-Group" to get the title. In reality, each code has a title so we can map both Title and Title2 to description

SELECT org_id, icnptso_code AS code, COALESCE(Title, Title2) as description,'ICNTPSO' as scheme, 'https://unstats.un.org/unsd/publication/seriesf/seriesf_91e.pdf' AS uri FROM stdin;
