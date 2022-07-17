#!/usr/bin/bash

# Vars
application_name=1
awx_url=$1
awx_token=$2
#desc_token="\'{ \"description\": \"auto_token_renew_$(date +%Y%m%d_%H%M%S)\" }\'"
desc_token="auto_token_renew_$(date +%Y%m%d_%H%M%S)"

# creation du nouveau token

output_cr_token=$(eval curl --silent -XPOST -H \"Content-Type: application/json\" -H \"Authorization: Bearer ${awx_token}\" -d \'{\"description\":\"${desc_token}\"}\' ${awx_url}/api/v2/applications/${application_name}/tokens/)

token_id=$(echo ${output_cr_token} | jq '.id')
token_new=$(echo ${output_cr_token} | jq '.token')
token_exp=$(echo ${output_cr_token} | jq '.expires')
token_user=$(echo ${output_cr_token} | jq '.summary_fields.user.username')
token_desc=$(echo ${output_cr_token} | jq '.description')

echo "############################################################"
echo "Last Token ID     : ${token_id}"
echo "New Token         : ${token_new}"
echo "Token Expiration  : ${token_exp}"
echo "User Token        : ${token_user}"
echo "Token Description : ${token_desc}"
echo "############################################################"

# purge des ancien token de ce user
output_list_token=$(eval curl --silent -XGET -H \"Content-Type: application/json\" -H \"Authorization: Bearer ${token_new}\" ${awx_url}/api/v2/applications/${application_name}/tokens/)
list_token_id=$(echo ${output_list_token} | jq '.results[].id')

for token_lun in ${list_token_id}
do
	if (( ${token_lun} != ${token_id} ))
	then
            output_delete_token=$(eval curl --silent -XDELETE -H \"Content-Type: application/json\" -H \"Authorization: Bearer ${token_new}\" ${awx_url}/api/v2/tokens/${token_lun}/)
	fi
done






