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
#    sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "shutdown /s /f /t 0"  # Force shutdown, to freeze fully

# If the run count is 1, unfreeze the machine (second time)
elif [[ "$RUN_COUNT" -eq 1 ]]; then
    echo "0" > "$RUN_COUNT_FILE"
    echo "Second execution: Unfreezing the remote machine by running a local batch file."

    # Create a temporary batch file on the remote machine to run explorer.exe
    TEMP_BAT_FILE="C:\\Users\\$USERNAME\\Desktop\\unfreeze.bat"
    sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "echo start explorer.exe > $TEMP_BAT_FILE"

    # Execute the batch file locally (the batch file will run in the user's session)
    echo "Running the temporary batch file to unfreeze the machine..."
    sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "start $TEMP_BAT_FILE"

    # Optionally wait for a few seconds to ensure explorer.exe starts properly
    sleep 2

    # Delete the temporary batch file after execution
    echo "Deleting the temporary batch file..."
    sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "del $TEMP_BAT_FILE"

else
    echo "Error: Invalid state in the run count file."
    exit 1
fi
