#!/bin/bash

SOURCE_DIR="./raw"
DEST_DIR="./json_and_CSV"

mkdir -p "$DEST_DIR"

echo "=== Moving CSV and JSON files ==="

if ls "$SOURCE_DIR"/*.csv >/dev/null 2>&1; then
    mv "$SOURCE_DIR"/*.csv "$DEST_DIR"/
    echo "CSV files moved."
else
    echo "No CSV files found."
fi

if ls "$SOURCE_DIR"/*.json >/dev/null 2>&1; then
    mv "$SOURCE_DIR"/*.json "$DEST_DIR"/
    echo "JSON files moved."
else
    echo "No JSON files found."
fi

echo "=== Done. Contents of $DEST_DIR: ==="
ls -l "$DEST_DIR"
