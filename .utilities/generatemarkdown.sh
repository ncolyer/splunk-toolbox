#!/bin/bash

# Function to create markdown file with Mermaid diagram
create_markdown() {
    local directory="$1"
    local foldername
    local foldername_safe
    local markdown_file
    local subdir_basename
    local subdir_safe
    local subdirs=()
    local letter="B"

    foldername=$(basename "$directory")
    markdown_file="$directory/${foldername}.md"

    # Replace spaces and hyphens with underscores for Mermaid compatibility
    foldername_safe=$(echo "$foldername" | sed 's/ /_/g' | sed 's/-/_/g')
    
    # Find subdirectories
    while IFS= read -r -d '' subdir; do
        subdirs+=("$subdir")
    done < <(find "$directory" -mindepth 1 -maxdepth 1 -type d -print0)

    if [ ${#subdirs[@]} -gt 0 ]; then
        # Create the Mermaid diagram structure
        {
            echo "# $foldername"
            echo
            echo '```mermaid'
            echo "graph TD;"
            echo "    Z[<a href=\"../\" target=\"_blank\" style=\"color:black\">Go Back to Index</a>]:::backLevelStyle"
            echo "    Z --> A[$foldername]:::firstLevelStyle"

            for subdir in "${subdirs[@]}"; do
                subdir_basename=$(basename "$subdir")
                subdir_safe=$(echo "$subdir_basename" | sed 's/ /_/g' | sed 's/-/_/g')

                # Check if the subdirectory contains any files or subdirectories
                if [ -n "$(find "$subdir" -mindepth 1 -print -quit)" ]; then
                    # Use secondLevelStyle for non-empty subdirectories with hyperlink
                    echo "    A --> ${letter}[<a href=\"$foldername_safe/$subdir_safe/\" target=\"_blank\" style=\"color:white\">$subdir_basename</a>]:::secondLevelStyle"
                else
                    # Use secondLevelStyleMissing for empty subdirectories and remove hyperlink
                    echo "    A --> ${letter}[$subdir_basename]:::secondLevelStyleMissing"
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
        } > "$markdown_file"
    fi
}

# Traverse directories and create markdown files
find . -type d -not -path '*/\.*' -not -path './data*' | while read -r directory; do
    if [ "$directory" != "." ]; then
        create_markdown "$directory"
    fi
done