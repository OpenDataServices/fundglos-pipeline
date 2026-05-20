# This jq filter is designed to be run at the end of the pipeline and will return a list of all the organisations in the dataset which do not have any classifications in their .classifications array.

(select((.recipient.classifications // []) == []) | [(.recipient.name | ascii_upcase | rtrimstr(" ")), .recipient.id]),
(select((.funder.classifications // []) == []) | [(.funder.name | ascii_upcase | rtrimstr(" ")), .funder.id]) | @csv


