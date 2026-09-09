# CoreDataEngineers ETL Project

## Overview
This project implements a simple ETL (Extract, Transform, Load) pipeline in Bash,
built and run from Git Bash on Windows. It downloads the NZ Annual Enterprise
Survey 2023 CSV, transforms it, and loads it into a Gold folder. It also includes
a separate script to organize CSV/JSON files, and is scheduled to run daily using
Windows Task Scheduler.

## Folder Structure
- `raw/` — raw downloaded CSV file (Extract stage)
- `Transformed/` — cleaned/selected columns (Transform stage)
- `Gold/` — final loaded output (Load stage)
- `json_and_CSV/` — destination folder for the file-mover script
- `etl_script.sh` — main ETL script
- `move_files.sh` — moves CSV/JSON files into json_and_CSV
- `etl_log.log` — scheduled run output log (git-ignored, regenerated on each run)

## Requirements
- Git Bash (MINGW64) on Windows
- GNU awk (gawk) — confirmed via `awk --version`, uses FPAT for correct CSV parsing
  of fields containing commas inside quotes
- curl

## How to Run the ETL Script
```bash
chmod +x etl_script.sh
./etl_script.sh
```

### What it does
1. **Extract**: Downloads the CSV from the URL stored in the `CSV_URL`
   environment variable, saves it to `raw/`, and confirms the save.
2. **Transform**: Renames `Variable_code` to `variable_code`, selects only
   `year, Value, Units, variable_code`, and saves to
   `Transformed/2023_year_finance.csv`. Uses gawk's FPAT feature to correctly
   handle CSV fields containing embedded commas inside quotes.
3. **Load**: Copies the transformed file into `Gold/` and confirms it.

## Scheduling: Windows Task Scheduler

Git Bash runs on MSYS2/MinGW and does not include a cron daemon (cron is a Linux
service, not available in this environment). Windows Task Scheduler is used
instead as the equivalent mechanism, configured to run daily at 12:00 AM.

**Task configuration:**
- Task name: `Daily ETL Job`
- Trigger: Daily, 12:00:00 AM
- Action → Program/script:

"C:\Program Files\Git\usr\bin\bash.exe"

- Action → Add arguments:

--login -c "cd /c/Users/AmarachiOrdor/coredata-project && ./etl_script.sh >> /c/Users/AmarachiOrdor/coredata-project/etl_log.log 2>&1"


**Why `--login` is required:** launching `bash.exe` directly (as Task Scheduler
does) starts a non-login, non-interactive shell that skips Git Bash's normal
profile setup. Without that setup, the `PATH` environment variable does not
include the directories containing core Unix utilities (`mkdir`, `awk`, `cp`,
etc.), causing them to fail with "command not found" even though the script
otherwise appears to complete. The `--login` flag forces bash to load its
profile scripts and set up `PATH` correctly, which was confirmed by comparing
`etl_log.log` output with and without the flag.

**To verify the schedule is active:**
- Open Task Scheduler (`taskschd.msc`) → find `Daily ETL Job` → check the
  "Last Run Result" column (`0x0` = success) or the History tab for run details.

## Moving CSV/JSON Files
```bash
chmod +x move_files.sh
./move_files.sh
```
Moves all `.csv` and `.json` files from `raw/` into `json_and_CSV/`. Works with
any number of files (one or many), and safely skips file types that aren't present
in the source folder.

## Known Limitations
- Task Scheduler configuration (trigger, action, arguments) is a Windows OS-level
  setting and is not itself version-controlled by git — it is documented here for
  reproducibility. To recreate the schedule on another machine, follow the
  configuration values listed above.
- The `--login` flag adds slight overhead per run (loading full profile scripts)
  but is required for reliable execution in this environment.
