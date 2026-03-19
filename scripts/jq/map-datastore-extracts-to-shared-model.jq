# This jq filter transforms input from the 360Giving Datastore extract in the source_data into the shared model for a funding opportunity


# =========================
# Helper Function
# =========================

def transform_organisation($org_data; $location_data):
# This function takes an organisation from 360Giving as input, as well as some location data if available, and maps it to the new shiny shared format we can use to analyse things.
# Importantly, it does its best to create identifier objects from the source data.
# There may be some cases where the organisation.id field is a well-formed GB-CHC or GB-COH identifier, but the data omits either/both the charityNumber and companyNumber field. This is mostly fine, because the fallback will create the identifier object properly


# First stage: capture some data to make lookups neater and pass that down to the next filter
		$org_data as $org
		| $location_data as $location
	
		# Second stage: build out the basics, including populating the .additional_identifiers array with charityNumber and companyNumber if we can
		| {
		    id: $org.id,
		    name: $org.name,
		    location: $location,
		    additionalIdentifiers: [
		    	($org.charityNumber | select(. != null) | {id: "GB-CHC-\(.)",identifier: ., scheme: "GB-CHC"}),
			($org.companyNumber | select(. != null) | {id: "GB-COH-\(.)",identifier: ., scheme: "GB-COH"})
		    ]
		} 
	
		# Third stage: we've built out the basics and we *might* have an identifiers array with a GB-CHC or GB-COH number in there. If that's the case, we want to re-use that as the primary identifier.
		# The order of preference is: GB-CHC -> GB-COH -> breaking apart the .id field and building that out as an identifier
		| . + {
			identifier: (
				(.additionalIdentifiers[] | select(.scheme == "GB-CHC")) //
				(.additionalIdentifiers[] | select(.scheme == "GB-COH")) //
				( ($org.id | split("-")) as $id_parts 
				| {
					id: $org.id, 
					scheme: ($id_parts[0:2] | join("-")), 
					identifier: ($id_parts[2:] | join("-"))
				})
				)
		}
;
# ======================================
# Main transformation
# ======================================

{

# Most of these are straightforward mappings.
# .type is set as "grant" because these are grants. The valid options according to the data model are "grant" or "procurement".
# The .uri field is consciously set as a grantnav url rather than mapping it from the source data, to achieve consistency and to support interfaces linking out to grantnav to see information about the grant there.
id: .grant_id,
type: "grant",
date: .data.awardDate,
value: {amount: .data.amountAwarded, currency: .data.currency},
uri: "https://grantnav.threesixtygiving.org/grant/\(.data.id)",

# In 360Giving, .grantProgramme is an array. This is likely to model cases where a grant belongs to more than one programme of work. As of 2026-03-19, the source data extracted from the 360Giving datastore contains no grants with more than one programme. I made a decision to reduce complication in the cleaned data by only taking the first entry in the .grantProgramme array here. If this changes, the job is just to use an array constructor and build a new object for each Grant Programme found in the source grant.
programme: {id: .data.grantProgramme[0].code, title: .data.grantProgramme[0].title, description: .data.grantProgramme[0].description, uri: .data.grantProgramme[0].url},

# For grants, the activity is taken from the title and description of the grant.
# activity.location is derived from the beneficiaryLocation in 360Giving as a proxy for where the work was being done or who it was targetting. Not all grants have beneficiaryLocation data, so we work with what we've got.
activity: {title: .data.title, description: .data.description, location: (.additional_data.locationLookup | map(select(.source == "beneficiaryLocation")))[0]},


# Data store data doesn't have any location lookup information for funding orgs. It's not what we're really interested in anyway. We do have a cute little classification for the funder from the datastore, though. So we don't want to waste that. We need to capture it before the function call to preserve it.
funder: ( .additional_data.TSGFundingOrgType as $funder_type
	| transform_organisation(.data.fundingOrganization[0]; null) 
	| . + {classifications: [{value: $funder_type, scheme: "TSG-FUNDING-ORG-TYPE"}]}
	), 

# Currently, this maps across recipientIndividuals as an "Organisation" object, but with a fixture omitting many of the identifier scheme fields and adding a custom classification.
recipient: (
	 if .data.recipientIndividual != null then {
	 					id: .data.recipientIndividual.id,
						name: "Recipient Individual",
						classifications: [{value: "INDIVIDUAL", scheme: "FUNDGLOS", description: "Individual Recipient of a Grant"}]
						}
	else
		transform_organisation(.data.recipientOrganization[0]; 
					.additional_data.locationLookup | map(select(.source == "recipientOrganizationLocation"))[0])

	end
	)

}
