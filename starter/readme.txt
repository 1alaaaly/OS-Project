# File Auditor & Backup Tool

## Project Description
A Bash tool that audits a directory and creates backups of readable files.

## Team Members
- Student 1: [Alaa Ali Mohamed] [2406012] - [lib.sh, backup_all(), list_backups(), restore_backup(), action from command line, menu]
- Student 2: [Asmaa Khaled Mohamed] [2406004] - [scan_directory(), permission_audit(), extension_report(), search_file()]

## How to Run

1. Open the terminal.
2. Navigate to the project folder:

```bash
cd starter
```

3. Run the script with the directory:

```bash
./auditor.sh ../sample_data
```

4. To run a specific action directly:

```bash
./auditor.sh ../sample_data scan
./auditor.sh ../sample_data perms
./auditor.sh ../sample_data ext
./auditor.sh ../sample_data backup
```

5. Choose an option from the menu to use the other features.

## Requirements
- Linux
- Bash
