#!/bin/bash

# Path to store the run count
RUN_COUNT_FILE="/home/it3/Desktop/TAPS/freezecomputer/runcount"

# Target file containing IP, username, and password
TARGET_FILE="/home/it3/Desktop/TAPS/freezecomputer/targets.txt"

# Read the target file and extract IP, username, and password
IP=$(awk '{print $1}' "$TARGET_FILE")
USERNAME=$(awk '{print $2}' "$TARGET_FILE")
PASSWORD=$(awk '{print $3}' "$TARGET_FILE")

# Check if the run count file exists and is not empty, if not, create it and initialize run count
if [[ ! -f "$RUN_COUNT_FILE" ]] || [[ ! -s "$RUN_COUNT_FILE" ]]; then
    echo "0" > "$RUN_COUNT_FILE"
fi

# Read the current run count from the file
RUN_COUNT=$(cat "$RUN_COUNT_FILE")

# If the run count is 0, freeze the machine (first time or after unfreeze)
if [[ "$RUN_COUNT" -eq 0 ]]; then
    echo "1" > "$RUN_COUNT_FILE"
    echo "First execution: Freezing the remote machine."

    # SSH into the remote machine and kill explorer.exe to freeze the computer
    sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "taskkill /f /im explorer.exe"

# If the run count is 1, unfreeze the machine (second time)
elif [[ "$RUN_COUNT" -eq 1 ]]; then
    echo "0" > "$RUN_COUNT_FILE"
    echo "Second execution: Using Task Scheduler to unfreeze the remote machine."

    # Create a task to start explorer.exe (using Task Scheduler)
    sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "schtasks /create /tn 'StartExplorer' /tr 'explorer.exe' /sc once /st 00:00 /ru SYSTEM"
    sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "schtasks /run /tn 'StartExplorer'"  # Run the scheduled task immediately

    # Optional: Remove the scheduled task after execution
    sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "schtasks /delete /tn 'StartExplorer' /f"

else
    echo "Error: Invalid state in the run count file."
    exit 1
fi
