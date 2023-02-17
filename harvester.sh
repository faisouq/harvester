#!/bin/bash

# This script uses theHarvester to find domains that give a response and posible e-mails.
# For better output configure the different API keys in the config file /etc/theHarvester/api-keys.yaml

if [ "$#" -lt 1 ]; then
    echo "Usage: ./`basename $0` domain"
    exit 1
fi

sources=(anubis baidu bevigil binaryedge bing bingapi bufferoverun censys certspotter crtsh dnsdumpster duckduckgo fullhunt github-code hackertarget hunter intelx omnisint \
 otx pentesttools projectdiscovery qwant rapiddns rocketreach securityTrails sublist3r threatcrowd threatminer urlscan virustotal yahoo zoomeye)
domains=()
emails=()
filtered_domains=()

for source in "${sources[@]}"; do
    domains+=($(theHarvester -d "$1" -b "$source" | grep -Pzo "Hosts found: (.*\n)*" | sed -e '1,2d' | cut -d ':' -f 1))
    emails+=($(theHarvester -d "$1" -b "$source" | sed -n '/Emails found/,/^$/p' | sed -e '1,2d' | cut -d ':' -f 1))
done

domains=($(printf '%s\n' "${domains[@]}" | sort -u))
for domain in "${domains[@]}"; do
    http_code=$(curl -m 3 --write-out %{http_code} --silent --no-keepalive --output /dev/null "$domain")
    if [[ "$http_code" != "000" ]]; then
        filtered_domains+=("$domain")
    fi
done

printf '%s\n' "${filtered_domains[@]}" > domains.txt

emails=($(printf '%s\n' "${emails[@]}" | sort -u))
printf '%s\n' "${emails[@]}" > emails.txt



