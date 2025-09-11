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
    sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "shutdown -h now"  # Force shutdown, to freeze fully

# If the run count is 1, unfreeze the machine (second time)
elif [[ "$RUN_COUNT" -eq 1 ]]; then
    echo "0" > "$RUN_COUNT_FILE"
    echo "Second execution: Unfreezing the remote machine."

    # Restart explorer.exe to unfreeze the computer
    sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "start explorer.exe"
else
    echo "Error: Invalid state in the run count file."
    exit 1
fi
