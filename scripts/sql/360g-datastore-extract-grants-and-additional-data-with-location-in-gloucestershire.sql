-- This query is derived from https://github.com/threeSixtyGiving/datastore/blob/live/tools/view_latest_grant.sql

-- The joins are necessary to avoid duplicates, due to how the datastore stores grant data and maps source files and grants to whether the grant is included in "current" dataset

-- The output of this is a JSON object with three keys:
-- 	grant_id: the id of the grant,
-- 	data: the original 360Giving grant data, in its entirety, in JSON
-- 	additional_data: the enriched data added by the datastore for this grant

-- The key to this query (other than the joins), is the `@>` on additional_data.locationLookup. This is because the datastore stores all the locationlookups for a particular grant in a single array on the addtional_data blob, and then references where it got that location from in the "locationLookup.source" key i.e. "recipientOrganization" or "beneficiaryLocation"
-- Further, the way that the location lookup works is that it can get whatever granularity the source data provides, and then backfill all the less-granular ones.
-- Therefore, enforcing that we only want grants where the "locationLookup[].utlacd" field (Upper Tier Local Authority Code) has a particular value means that every grant will have some form of location in Gloucestershire, with many hopefully having finer grain detail as well.
-- However, we don't know at this stage whether this location is for the recipient organisation's locatin, the beneficiary location, or both. This is mapped appropriately later in the pipeline.

SELECT jsonb_build_object('grant_id', grant_id, 'data', db_grant.data, 'additional_data', db_grant.additional_data)
FROM db_grant
	JOIN db_sourcefile_latest ON db_grant.source_file_id = db_sourcefile_latest.sourcefile_id
     	JOIN db_latest ON db_sourcefile_latest.latest_id = db_latest.id
     	JOIN db_sourcefile on db_grant.source_file_id = db_sourcefile.id
     	JOIN db_publisher ON db_publisher.prefix = db_sourcefile.data -> 'publisher' ->> 'prefix'
WHERE db_latest.series = 'CURRENT'::text AND db_grant.additional_data @> '{"locationLookup": [{"utlacd": "E10000013"}]}';
