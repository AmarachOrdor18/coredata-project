# CoreDataEngineers ETL Project

## Overview
This project implements a simple ETL (Extract, Transform, Load) pipeline in Bash,
run from Git Bash on Windows. It downloads the NZ Annual Enterprise Survey 2023
CSV, transforms it, and loads it into a Gold folder. It also includes a separate
script to organize CSV/JSON files, and is scheduled to run daily via Windows Task
Scheduler (the Git-Bash-compatible equivalent of cron, since cron is a Linux
daemon not available in the Git Bash/MSYS2 environment).

## Folder Structure
- `raw/` — raw downloaded CSV file (Extract stage)
- `Transformed/` — cleaned/selected columns (Transform stage)
- `Gold/` — final loaded output (Load stage)
- `json_and_CSV/` — destination folder for the file-mover script
- `etl_script.sh` — main ETL script
- `move_files.sh` — moves CSV/JSON files into json_and_CSV
- `etl_log.log` — scheduled run output log

## Requirements
- Git Bash (MINGW64) on Windows
- gawk (for FPAT-based CSV parsing) — or plain awk with the known limitation noted below
- curl

## How to Run the ETL Script
```bash
chmod +x etl_script.sh
./etl_script.sh
```

## Scheduling
Git Bash does not include a cron daemon, so this task is scheduled with Windows
Task Scheduler instead:
- Trigger: Daily at 12:00 AM
- Action: `bash.exe -c "cd /c/path/to/coredata-project && ./etl_script.sh >> etl_log.log 2>&1"`

## Moving CSV/JSON Files
```bash
chmod +x move_files.sh
./move_files.sh
```

## Known Limitations
- Requires gawk's FPAT feature for correct CSV parsing of fields containing commas
  inside quotes; if unavailable, plain awk -F',' was used and may misparse a small
  number of rows with embedded commas.
