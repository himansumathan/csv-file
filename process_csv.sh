#!/bin/bash

# Helper function to trim leading and trailing spaces
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

# Helper function to sanitize URLs and titles
sanitize() {
    local input="$*"
    input=$(echo "$input" | sed 's/[^a-zA-Z0-9.-\/]//g') # Remove special characters except for . / -
    echo "$input"
}

# Process input CSV file
process_csv() {
    local input_file="$1"
    local output_file="output.csv"

    # Initialize arrays for URLs and titles
    declare -a urls categories
    declare -A titles

    # Read input CSV file line by line
    while IFS=',' read -r url title; do
        url=$(trim "$url")
        title=$(trim "$title")

        # Sanitize URL and title
        url=$(sanitize "$url")
        title=$(sanitize "$title")

        # Extract common prefix and category from URL
        prefix=$(echo "$url" | awk -F/ '{print $1"/"$2"/"$3}')
        category=$(echo "$url" | awk -F/ '{print $4}')

        # Store URLs and categories
        urls+=("$prefix")
        categories+=("$category")

        # Store titles in an associative array
        titles["$prefix,$category"]="${titles["$prefix,$category"]}$title;"
    done < "$input_file"

    # Write header row to output CSV file
    echo "URL,overview,campus,courses,scholarships,admission,placements,results" > "$output_file"

    # Iterate through unique URLs and categories
    for i in "${!urls[@]}"; do
        url="${urls[$i]}"
        category="${categories[$i]}"
        prefix="$url,$category"

        # Write row to output CSV file
        echo -n "$url," >> "$output_file"
        for c in overview campus courses scholarships admission placements results; do
            title="${titles["$url,$c"]%?}"
            echo -n "$title," >> "$output_file"
        done
        echo "" >> "$output_file"
    done
}

# Check if input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file.csv>"
    exit 1
fi

# Process input CSV file
process_csv "$1"
