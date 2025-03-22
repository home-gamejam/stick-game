#!/bin/bash

# Script to delete all .uid files in a Godot project

# Check if we're in a Godot project directory
if [ ! -f "project.godot" ]; then
    echo "Error: No 'project.godot' file found. Please run this script from the root of a Godot project."
    exit 1
fi

# Default directory to search (current directory)
SEARCH_DIR="."

# Optional: Dry run mode (just list files without deleting)
DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
    DRY_RUN=true
    echo "Running in dry-run mode. No files will be deleted."
fi

# Count of .uid files found
count=0

# Find and process all .uid files
echo "Searching for .uid files in $SEARCH_DIR..."
find "$SEARCH_DIR" -type f -name "*.uid" | while read -r uid_file; do
    if [ "$DRY_RUN" = true ]; then
        echo "Would delete: $uid_file"
    else
        rm -f "$uid_file"
        if [ $? -eq 0 ]; then
            echo "Deleted: $uid_file"
        else
            echo "Failed to delete: $uid_file"
        fi
    fi
    ((count++))
done

# Summary
if [ "$count" -eq 0 ]; then
    echo "No .uid files found."
else
    echo "Found and processed $count .uid files."
fi

echo "Operation complete."