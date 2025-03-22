#!/bin/bash

# Script to find orphaned .uid files in a Godot project

# Check if we're in a Godot project directory
if [ ! -f "project.godot" ]; then
    echo "Error: No 'project.godot' file found. Please run this script from the root of a Godot project."
    exit 1
fi

# Directory to search (default is current directory)
SEARCH_DIR="."

# Temporary file to store results
TEMP_FILE=$(mktemp)

# Find all .uid files and check their corresponding resources
find "$SEARCH_DIR" -type f -name "*.uid" | while read -r uid_file; do
    # Extract the UID from the file name (e.g., uid://abc123.tres.uid -> abc123)
    uid=$(basename "$uid_file" | sed 's/\.uid$//')

    # Look for references to this UID in project files
    # Typically, UIDs are stored in .tscn, .tres, .gd, etc., as "uid://<id>"
    uid_ref="uid://$uid"

    # Check if the UID is referenced anywhere in the project
    if ! grep -r "$uid_ref" "$SEARCH_DIR"/*.tscn "$SEARCH_DIR"/*.tres "$SEARCH_DIR"/*.gd 2>/dev/null | grep -v "$uid_file" > "$TEMP_FILE"; then
        # If no references are found, check if the corresponding resource file exists
        # UIDs are often tied to a file with the same base name (e.g., scene.tscn -> scene.tscn.uid)
        base_file=$(echo "$uid_file" | sed 's/\.uid$//')
        if [ ! -f "$base_file" ]; then
            echo "Orphaned .uid file: $uid_file (no corresponding resource or references found)"
        fi
    fi
done

# Clean up temporary file
rm -f "$TEMP_FILE"

echo "Scan complete."