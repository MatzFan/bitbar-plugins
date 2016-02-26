#!/bin/bash

export PATH=/usr/local/bin:$PATH # for brews
# next two to be read from ENV
SURVEYMONKEY_APIKEY=u366xz3zv6s9jje5mm3495fk
SURVEYMONKEY_ACCESSTOKEN=zpCB90SBQEXa.i02BOTdna1u.pt7D4ad8Z0UgP0NG1zxRcZDSQ9.oL2F6ubguUxYCkVI-EGL8.d5zXX88sjFFX5RS.5T0tE3aP6abPrH3wfA5yElV5FrxRJXXsjXZzF6
referer="Referer: https://developer.surveymonkey.com/tools/api_console/"
json="Content-Type: application/json"
base_url="https://api.surveymonkey.net/v2/"
token="Authorization: bearer ${SURVEYMONKEY_ACCESSTOKEN}"
api_key="api_key=${SURVEYMONKEY_APIKEY}"

declare -a survey_array

api_call() # $1 is path, $2 is method, $3 is json return fields
{
  echo "$(curl -s -H "${referer}" -H "${json}" -H "${token}" "${base_url}${1}/${2}?${api_key}" --data-binary ${3})"
}

surveys()
{
  params='{"fields":["title","survey_id"]}'
  json="$(api_call surveys get_survey_list $params)"
  echo "$(echo "$json" | jq '.data.surveys')"
}

collectors() # $1 is survey_id
{
  params='{"survey_id":"'${1}'","fields":["name"]}'
  json="$(api_call surveys get_collector_list $params)"
  echo "$(echo "$json" | jq '.data.collectors')"
}

responses()
{
  params='{"collector_id": "81350599"}'
  json="$(api_call surveys get_response_counts $params)"
}

build_collector_array()
{
  while IFS="=" read -r key value
  do
    collector_array[$key]="$value"
  done < <(collectors "$1" | jq -r "to_entries|map(\"\(.key)=\(.value)\")|.[]") # function call to collectors() with survey_id
}

build_survey_array()
{
  while IFS="=" read -r key value
  do
    survey_array[$key]="$value"
  done < <(surveys | jq -r "to_entries|map(\"\(.key)=\(.value)\")|.[]") # function call to surveys()
}

print_collectors()
{
  for i in "${!collector_array[@]}"
  do
    collector="${collector_array[$i]}"
    name=$(echo "$collector" | jq '.name' | sed 's/\"//g') # assume unique titles
    collector_id=$(echo "$collector" | jq '.collector_id' | sed 's/\"//g')
    echo "$name:$collector_id"
  done
}

print_surveys_and_collectors()
{
  for i in "${!survey_array[@]}"
  do
    survey="${survey_array[$i]}"
    title=$(echo "$survey" | jq '.title' | sed 's/\"//g') # assume unique titles
    survey_id=$(echo "$survey" | jq '.survey_id' | sed 's/\"//g')
    echo "$title:$survey_id"

    build_collector_array "$survey_id"
    print_collectors
  done
}

if [[ "$1" = "show_survey" ]]; then
  say "$2"
  exit
fi

echo 🐵
echo ---
echo "Surveys"

build_survey_array
print_surveys_and_collectors
