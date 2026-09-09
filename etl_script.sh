#!/bin/bash

# ===== ENVIRONMENT VARIABLE FOR THE SOURCE URL =====
export CSV_URL="https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2023-financial-year-provisional/Download-data/annual-enterprise-survey-2023-financial-year-provisional.csv"

# ===== FOLDER AND FILE VARIABLES =====
RAW_DIR="raw"
TRANSFORMED_DIR="Transformed"
GOLD_DIR="Gold"
RAW_FILE="$RAW_DIR/annual-enterprise-survey-2023-financial-year-provisional.csv"
TRANSFORMED_FILE="$TRANSFORMED_DIR/2023_year_finance.csv"

# ===== EXTRACT =====
echo "=== EXTRACT: Downloading CSV file ==="
mkdir -p "$RAW_DIR"
curl -s -o "$RAW_FILE" "$CSV_URL"

if [ -f "$RAW_FILE" ]; then
    echo "SUCCESS: File saved to $RAW_FILE"
else
    echo "ERROR: File was not downloaded. Exiting."
    exit 1
fi

# ===== TRANSFORM =====
echo "=== TRANSFORM: Renaming column and selecting fields ==="
mkdir -p "$TRANSFORMED_DIR"

awk -v FPAT='[^,]*|"[^"]*"' -v OFS=',' '
NR==1 {
    for (i=1; i<=NF; i++) {
        col=$i
        gsub(/^"|"$/, "", col)
        if (col=="Variable_code") { varcode_idx=i }
        if (col=="Year")          { year_idx=i }
        if (col=="Value")         { value_idx=i }
        if (col=="Units")         { units_idx=i }
    }
    print "year,Value,Units,variable_code"
    next
}
{
    print $year_idx, $value_idx, $units_idx, $varcode_idx
}' "$RAW_FILE" > "$TRANSFORMED_FILE"

if [ -f "$TRANSFORMED_FILE" ]; then
    echo "SUCCESS: Transformed file saved to $TRANSFORMED_FILE"
else
    echo "ERROR: Transformation failed. Exiting."
    exit 1
fi

# ===== LOAD =====
echo "=== LOAD: Loading transformed data into Gold ==="
mkdir -p "$GOLD_DIR"
cp "$TRANSFORMED_FILE" "$GOLD_DIR/"

if [ -f "$GOLD_DIR/2023_year_finance.csv" ]; then
    echo "SUCCESS: File loaded into $GOLD_DIR"
else
    echo "ERROR: Load step failed."
    exit 1
fi

echo "=== ETL PROCESS COMPLETE ==="
