#!/usr/bin/env bash

function decode_header()
{
    python <<EOL
from email.header import decode_header
print decode_header('$@')[0][0]
EOL
}

out=~/.lbdb/m_inmail.list

date_format='%Y-%m-%d %H:%M'
date=$(date +"$date_format")

key_value='^([^ :]+):[ ]*(.+)$'
name_email='^([^<>]+)[ ]*<(.+)>$'

while IFS=$'\n' read line; do
    [[ "$line" =~ $key_value ]] || continue

    key="${BASH_REMATCH[1]}"
    val="${BASH_REMATCH[2]}"

    if [ "$key" = Date ]; then
        date=$(date -d"$val" +"$date_format")
    fi

    if [[ "$key" =~ ^(From|To|CC)$ ]]; then
        if [[ "$val" =~ $name_email ]]; then
            name="${BASH_REMATCH[1]%% }"
            email="${BASH_REMATCH[2]}"
        else
            email="$val"
            name="$val"
        fi

        name="$(decode_header "$name")"

        printf "%s\t%s\t%s\n" "$email" "$name" "$date"
    fi
done | sort -u -t$'\t' -k1,1 -o $out $out -
