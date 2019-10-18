#!/bin/sh

source ./test-common.sh

PAYLOAD=$1
curl -X POST --data-urlencode \
     "payload={\"channel\": \"#$SLACK_CH\", \"username\": \"webhookbot\", \"text\": \"$PAYLOAD\", \"icon_emoji\": \":iphone:\"}" \
     https://hooks.slack.com/services/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
