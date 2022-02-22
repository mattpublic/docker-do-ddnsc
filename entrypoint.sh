#!/bin/bash

function get_ip {
	curl --silent https://ifconfig.co 2>/dev/null
}

function get_record_id {
	curl --silent --request GET \
		--header "Content-Type: application/json" \
       		--header "Authorization: Bearer $DOKEY" \
		"https://api.digitalocean.com/v2/domains/$DOMAIN/records?per_page=200" | \
		jq ".[\"domain_records\"] | . [] | select(.name==\"$HOST\") | .id" 2>/dev/null
}

record_id=$(get_record_id)

echo using record_id $record_id

function post_ip {
	curl --silent -X PUT \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $DOKEY" \
		-d '{"data":"'$1'"}' \
		"https://api.digitalocean.com/v2/domains/$DOMAIN/records/$record_id" > /dev/null
}

function report_status {
	if [ $1 -eq 0 ]; then 
		echo "$HOST.$DOMAIN -> $2";
	else \
		echo "failed setting $HOST.$DOMAIN -> $2 from $1";
	fi
}

ip=$(get_ip)
new_ip=$ip

post_ip $ip

report_status $? $ip $new_ip

while sleep $CHECK; do
	new_ip=$(get_ip)
	if [ "$new_ip" == "$ip" ]; then
		continue
	fi
	if post_ip $new_ip; then
		ip=$new_ip
	fi
	report_status $? $ip $new_ip
done
