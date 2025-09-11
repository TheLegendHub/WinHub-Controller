#!/bin/bash

# Path to store the run count
RUN_COUNT_FILE="/home/it3/Desktop/TAPS/freezecomputer/runcount"

# Target file containing IP, username, and password
TARGET_FILE="/home/it3/Desktop/TAPS/freezecomputer/targets.txt"
TARGET2_FILE="/home/it3/Desktop/TAPS/freezecomputer/targets_2.txt"

# Read the target file and extract IP, username, and password
IP=$(awk '{print $1}' "$TARGET_FILE")
USERNAME=$(awk '{print $2}' "$TARGET_FILE")
PASSWORD=$(awk '{print $3}' "$TARGET_FILE")
USERNAME1=$(awk '{print $1}' "$TARGET2_FILE")
PASSWORD1=$(awk '{print $2}' "$TARGET2_FILE")
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

    # Create a batch file to run explorer.exe on the remote machine
    #BATCH_FILE_PATH="C:\\Users\\$USERNAME\\Desktop\\unfreeze.bat"
    BATCH_FILE_PATH="C:\\Users\\$USERNAME1\\Desktop\\unfreeze.bat"

    sshpass -p "$PASSWORD1" ssh "$USERNAME1"@"$IP" "echo start explorer.exe > $BATCH_FILE_PATH"

    # Create a scheduled task to execute the batch file immediately
    echo "Creating scheduled task to run the batch file immediately"
    sshpass -p "$PASSWORD1" ssh "$USERNAME1"@"$IP" "schtasks /create /tn 'RunFreezeUnfreeze' /tr '$BATCH_FILE_PATH' /sc once /st $(date +"%H:%M") /f"
    #sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "schtasks /create /tn 'RunFreezeUnfreeze' /tr '$BATCH_FILE_PATH' /sc once /f"
    #sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "schtasks /create /tn 'RunFreezeUnfreeze' /tr '$BATCH_FILE_PATH' /sc once /st $(date -d '+3 sec' +"%H:%M") /f"
    #sshpass -p "$PASSWORD" ssh "$USERNAME"@"$IP" "schtasks /create /tn 'RunFreezeUnfreeze' /tr '$BATCH_FILE_PATH' /sc once /st $(date -d '+3 sec' +"%H:%M") /f"
    #sshpass -p "$PASSWORD1" ssh "$USERNAME1"@"$IP" "schtasks /create /tn 'RunFreezeUnfreeze' /tr '$BATCH_FILE_PATH' /sc once /st $(date +"%H:%M") /f"

    # Run the scheduled task immediately
    sshpass -p "$PASSWORD1" ssh "$USERNAME1"@"$IP" "schtasks /run /tn 'RunFreezeUnfreeze'"

    # Wait for the task to run and finish (optional)
    echo "Waiting for the task to complete..."
    sleep 2

    # Delete the scheduled task after execution
    echo "Deleting the scheduled task..."
    sshpass -p "$PASSWORD1" ssh "$USERNAME1"@"$IP" "schtasks /delete /tn 'RunFreezeUnfreeze' /f"

    # Optionally, delete the batch file after execution
    echo "Deleting the temporary batch file..."
    sshpass -p "$PASSWORD1" ssh "$USERNAME1"@"$IP" "del $BATCH_FILE_PATH"

else
    echo "Error: Invalid state in the run count file."
    exit 1
fi
