#!/usr/bin/env bash

# Function to convert a string to title case
to_title_case() {
    echo "$1" | sed 's/_/ /g' | sed 's/\b\(.\)/\u\1/g'
}

# Function to create markdown file with Mermaid diagram
create_markdown() {
    local directory="$1"
    local subdir_basename
    local subdir_safe
    local subdirs=()
    local letter="B"

    # Repository URL
    local github_url="https://github.com/ncolyer/splunk-toolbox/blob/main/data"
    
    # Folder name
    local foldername
    foldername=$(basename "$directory")
    
    # Markdown file name
    local markdown_file="$directory/README.md"

    # Replace spaces and hyphens with underscores for Mermaid compatibility
    local foldername_safe
    foldername_safe=$(echo "$foldername" | sed 's/ /_/g' | sed 's/-/_/g')

    # Find subdirectories
    while IFS= read -r -d '' subdir; do
        subdirs+=("$subdir")
    done < <(find "$directory" -mindepth 1 -maxdepth 1 -type d -print0)

    # Create the Mermaid diagram if there are subdirectories
    if [ ${#subdirs[@]} -gt 0 ]; then
        {
            # Create the Mermaid diagram structure
            echo "# $(to_title_case "$foldername")"
            echo
            echo '```mermaid'
            echo "graph TD;"
            echo "    Z[<a href=\"$github_url\" target=\"_blank\" style=\"color:black\">Go Back</a>]:::backLevelStyle"
            echo "    Z --> A[$foldername_safe]:::firstLevelStyle"

            for subdir in "${subdirs[@]}"; do
                subdir_basename=$(basename "$subdir")
                subdir_safe=$(echo "$subdir_basename" | sed 's/ /_/g' | sed 's/-/_/g')

                # Generate the correct URL by replacing the path
                if [ -n "$(find "$subdir" -mindepth 1 -print -quit)" ]; then
                    url_path="${github_url}/${subdir_safe}/"
                    # Use secondLevelStyle for non-empty subdirectories with correct hyperlink
                    echo "    A --> ${letter}[<a href=\"$url_path\" target=\"_blank\" style=\"color:white\">$subdir_basename</a>]:::secondLevelStyle"
                else
                    # Use secondLevelStyleMissing for empty subdirectories and remove hyperlink
                    echo "    A --> ${letter}[$subdir_safe]:::secondLevelStyleMissing"
                fi

                # Increment the letter for the next node
                letter=$(echo "$letter" | tr "A-Y" "B-ZA")
            done

            echo
            echo "    classDef backLevelStyle fill:#e74c3c,stroke:#333,stroke-width:2px,color:#ffffff;"
            echo "    classDef firstLevelStyle fill:#6188b9,stroke:#333,stroke-width:2px;"
            echo "    classDef secondLevelStyle fill:#34495e,stroke:#333,stroke-width:2px;"
            echo "    classDef secondLevelStyleMissing fill:#000000,stroke:#333,stroke-width:2px;"
            echo '```'
        } >"$markdown_file"
    fi
}

# Function to append verb documentation to the markdown file
create_verb_markdown() {
    local directory="$1"
    local foldername
    foldername=$(basename "$directory")
    local title_case_foldername
    title_case_foldername=$(to_title_case "$foldername")
    local markdown_file="$directory/README.md"
    
    # Print the header
    {
        echo " "
        echo "# $title_case_foldername - Verb Documentation"
        echo " "
        printf "%-25s %-25s %-25s %-25s\n" "Category" "Type" "Functionality" "Specifics"
    } >> "$markdown_file"

    # Find all .spl files in the specified directory, process and format their names
    find "$directory" -type f -name "*.spl" | while read -r file; do
        # Extract the filename without the path and extension
        filename=$(basename "$file" .spl)
        
        # Split the filename into an array using underscore as a delimiter
        IFS='_' read -r -a parts <<< "$filename"
        
        # Print the first four elements of the array, formatted for even spacing, and append to the markdown file
        printf "%-25s %-25s %-25s %-25s\n" "${parts[0]}" "${parts[1]}" "${parts[2]}" "${parts[3]}"
    done | sort | uniq >> "$markdown_file"
}

# Traverse directories and create markdown files
find ./data -type d -not -path '*/\.*' | while read -r directory; do
    if [ "$directory" != "./data" ]; then
        create_markdown "$directory"
        create_verb_markdown "$directory"
    fi
done