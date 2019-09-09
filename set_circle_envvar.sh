#!/usr/bin/env bash
# shellcheck disable=SC2016
set -eu

repo=planet4-rss-to-chat-vulnerable-plugins
user=greenpeace
var_name=$1
var_value=$2


json=$(jq -n \
  --arg NAME "$var_name" \
  --arg VALUE "$var_value" \
'{
	"name": $NAME,
  "value": $VALUE
}')

curl \
  -u "${CIRCLE_TOKEN}:" \
  -X DELETE \
  "https://circleci.com/api/v1.1/project/github/${user}/${repo}/envvar/${var_name}"

curl \
  -u "${CIRCLE_TOKEN}:" \
  -X POST \
  --header "Content-Type: application/json" \
  -d "$json" \
  "https://circleci.com/api/v1.1/project/github/${user}/${repo}/envvar"
