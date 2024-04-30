#!/bin/bash
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"  
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}
sanitize() {
    local input="$*"
    input=$(echo "$input" | sed 's/[^a-zA-Z0-9.-\/]//g') 
    echo "$input"
}
process_csv() {
    local input_file="$1"
    local output_file="output.csv"
    
    declare -a urls categories
    declare -A titles

    while IFS=',' read -r url title; do
        url=$(trim "$url")
        title=$(trim "$title")

        url=$(sanitize "$url")
        title=$(sanitize "$title")

        prefix=$(echo "$url" | awk -F/ '{print $1"/"$2"/"$3}')
        category=$(echo "$url" | awk -F/ '{print $4}')

        urls+=("$prefix")
        categories+=("$category")

        titles["$prefix,$category"]="${titles["$prefix,$category"]}$title;"
    done < "$input_file"

    echo "URL,overview,campus,courses,scholarships,admission,placements,results" > "$output_file"

    for i in "${!urls[@]}"; do
        url="${urls[$i]}"
        category="${categories[$i]}"
        prefix="$url,$category"

        echo -n "$url," >> "$output_file"
        for c in overview campus courses scholarships admission placements results; do
            title="${titles["$url,$c"]%?}"
            echo -n "$title," >> "$output_file"
        done
        echo "" >> "$output_file"
    done
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file.csv>"
    exit 1
fi

process_csv "$1"
