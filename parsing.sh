#!/bin/bash

# This script parses an HTML file and extracts the URLs from the href attributes in the body section.
# It then performs a DNS lookup on each URL and saves the results to an output file.

DEFAULT_OUTPUT_FILE="../output.txt"      # Default output file path
DEFAULT_INDEX_FILE="index.html"          # Default index file name
TEMP_FOLDER_NAME="tempScript"            # Temporary folder name
TARGET_URL=$1                            # URL to parse

# Function to filter href attributes from the HTML body section
function filter_href_html {
    grep "<body" -A 99999 | grep "href" | cut -d "=" -f 2 | cut -d ">" -f 1 | grep "\." | sed 's/"//g' | cut -d "/" -f 3
}

# Create temporary folder and navigate into it
mkdir "$TEMP_FOLDER_NAME" && cd "$TEMP_FOLDER_NAME" || exit 1

# Download the HTML file from the target URL
wget "$TARGET_URL"

# Extract URLs, perform DNS lookup, and save results to an array
data=$(cat "$DEFAULT_INDEX_FILE" | filter_href_html | sort -u)
data_array=()

while IFS= read -r line; do
    line="[ $(dig +short "$line") ]: $line"
    data_array+=("$line")
    echo "$line"
done <<< "$data"

# Save the array of results to the output file
printf '%s\n' "${data_array[@]}" > "$DEFAULT_OUTPUT_FILE"

# Navigate back to the parent directory and remove the temporary folder
cd .. && rm -r "$TEMP_FOLDER_NAME"
