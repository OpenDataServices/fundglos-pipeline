# This filter is designed to support optimising the pipeline.
# As input, it expects data mapped to the common format.
# As output, it will produce a simple text list of identifiers in the data
# It will not attempt to de-duplicate things, pass the output to `sort --unique` first

.recipient.id,
.recipient.identifier?.id,
.recipient.additionalIdentifiers[]?.id?,
.funder.id,
.funder.identifier?.id,
.funder.additionalIdentifiers[]?.id?
