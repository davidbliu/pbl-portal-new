#!/bin/bash

# Testing on two devices
# REG_ID_0="APA91bF1hKyB_LVEO3e-Pm4jKdJaXtq1sMIW8bs6Rbzen2wefjYmSdfprd3-P1iQz2vp_kn8C1RNTpwWDFrS2hoTFo-Wj6dwzUDMIXd4rYjeJve1atbxB8iRt-6VVGrC0cg7Q94fGGl61yvCE4XcuBu9rhXJtkO1NQ"
# # REG_ID_1=""

# AUTH="AIzaSyCJXoIDvE-NvD3mZ1IXVclALgoKfs8YPgM"
# curl https://android.googleapis.com/gcm/send \
#   -H 'Content-Type: application/json' \
#   -H 'Authorization: key=${AUTH}' \
#   -d '{ "registration_ids": ["'${REG_ID_0}'"]
#       , "data": { "foo": "bzawhahahawawaHAHA" }
#       }'


api_key="AIzaSyBe6RSXBWWsuGNWSOkO_j4ULUNzXv8BfK4"
reg_id="APA91bF1hKyB_LVEO3e-Pm4jKdJaXtq1sMIW8bs6Rbzen2wefjYmSdfprd3-P1iQz2vp_kn8C1RNTpwWDFrS2hoTFo-Wj6dwzUDMIXd4rYjeJve1atbxB8iRt-6VVGrC0cg7Q94fGGl61yvCE4XcuBu9rhXJtkO1NQ"
# curl --header "Authorization: key=$api_key" --header Content-Type:"application/json" https://android.googleapis.com/gcm/send  -d "{\"registration_ids\":[\"$reg_id\"],\"data\":{\"code\":123}}"


# AUTH="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# curl https://android.googleapis.com/gcm/send \
#   -H 'Content-Type: application/json' \
#   -H 'Authorization: key=${api_key}' \
#   -d '{ "registration_ids": ["'${reg_id}'"]
#       , "data": { "foo": "bzawhahahawawaHAHA" }
#       }'

curl --header "Authorization: key=${api_key}" --header "Content-Type: application/json" https://android.googleapis.com/gcm/send -d "{\"registration_ids\":[\"${reg_id}\"]}"