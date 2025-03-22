#!/bin/bash

# Script to check all res:// paths in a Godot project and verify they exist in the filesystem

# Check if we're in a Godot project directory
if [ ! -f "project.godot" ]; then
    echo "Error: No 'project.godot' file found. Please run this script from the root of a Godot project."
    exit 1
fi

# Directory to search (current directory)
SEARCH_DIR="."

# Temporary file to store unique res:// paths
TEMP_FILE=$(mktemp)

# Counter for missing files
missing_count=0

# Find all res:// paths in .tscn, .tres, .gd, and .import files
echo "Scanning for res:// paths in $SEARCH_DIR..."
grep -r "res://[^\"']*" "$SEARCH_DIR"/*.tscn "$SEARCH_DIR"/*.tres "$SEARCH_DIR"/*.gd "$SEARCH_DIR"/*.import 2>/dev/null | \
    sed 's/.*\(res:\/\/[^"'\'' ]*\).*/\1/' | \
    sort -u > "$TEMP_FILE"

# Check each path's existence
while read -r res_path; do
    # Convert res:// path to filesystem path (remove res:// prefix)
    fs_path="$SEARCH_DIR/${res_path#res://}"

    # Check if the file exists
    if [ ! -f "$fs_path" ]; then
        echo "Missing file: $res_path (referenced but not found)"
        ((missing_count++))
    fi
done < "$TEMP_FILE"

# Clean up temporary file
rm -f "$TEMP_FILE"

# Summary
if [ "$missing_count" -eq 0 ]; then
    echo "No missing res:// paths found."
else
    echo "Found $missing_count missing res:// paths."
fi

echo "Scan complete."