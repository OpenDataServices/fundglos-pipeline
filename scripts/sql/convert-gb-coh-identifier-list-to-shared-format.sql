-- This query is designed to be used with `csvsql` to transform the list of Companies house numbers into a csv file with the header of "name,org_id"

-- Note: the company number field has an errant space in it, so that is reflected here.
-- This also prefixes the company number with "GB-COH" to use as a proper org-id.
-- Also note that there is semantic difference between single and double quotes. Single quotes are string literals, whereas double quotes are used to escape dodgy column names!

SELECT CompanyName AS name, 'GB-COH-' || " CompanyNumber" AS org_id FROM stdin;
