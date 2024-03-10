#!/bin/bash

DEFAULT_OUTPUT_FILE="../output.txt"
DEFAULT_INDEX_FILE="index.html"
TEMP_FOLDER_NAME="tempScript"
TARGET_URL=$1

function filter_href_html {
  grep "<body" -A 99999 | grep "href" | cut -d "=" -f 2 | cut -d ">" -f 1 | grep "\." | sed 's/"//g' | cut -d "/" -f 3
}

mkdir $TEMP_FOLDER_NAME && cd $TEMP_FOLDER_NAME
wget $TARGET_URL

data=$(cat $DEFAULT_INDEX_FILE | filter_href_html | sort | uniq)
data_array=()

while IFS=$'\n' read -r line; do
  line=("[$(dig +short $line)]: $line")
  data_array+=$line
  echo $line
done <<< "$data"

echo ${data_array[@]} > $DEFAULT_OUTPUT_FILE

cd ..
rm -r $TEMP_FOLDER_NAME