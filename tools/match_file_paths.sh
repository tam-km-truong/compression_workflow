#!/bin/bash

# Check if the correct number of arguments is provided
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <path_file> <tree_reordered_files> <processed_file>"
    exit 1
fi

# Assign arguments to variables
first_file="$1"
second_file="$2"
output_file="$3"

# Ensure output file is empty before writing
> "$output_file"

# Loop through each filename in the second file
while IFS= read -r filename; do
    # Use grep to find the full path in the first file, handling both cases (.gz or no .gz)
    line_full=$(grep -E "/${filename}(\.gz)?$" "$first_file")
    
    # If found, write to the output file
    if [[ -n "$line_full" ]]; then
        echo "$line_full" >> "$output_file"
    fi
done < "$second_file"
