#!/bin/bash

# Path to the file containing the list of target machines, users, and passwords
TARGETS_FILE="/home/it3/Desktop/TAPS/shutdownscript/targets.txt"

# Check if the targets file exists
if [[ ! -f $TARGETS_FILE ]]; then
    echo "Error: $TARGETS_FILE not found. Please create this file with 'IP USER PASSWORD' per line."
    exit 1
fi

# Iterate over each line in the list
while IFS=" " read -r TARGET USER PASSWORD; do
    if [[ -z $TARGET || -z $USER || -z $PASSWORD ]]; then
        continue  # Skip empty lines or malformed lines
    fi

    echo "Toggling freeze state on $TARGET with user $USER..."

    # Execute the SSH command to check if explorer.exe is running
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -T "$USER@$TARGET" << 'EOF'
    tasklist | findstr /I explorer.exe >nul
    if %ERRORLEVEL% equ 0 (
        echo "Explorer is running. Terminating..."
        taskkill /F /IM explorer.exe
    ) else (
        echo "Explorer is not running. Restarting..."
        start explorer.exe
    )
EOF

    if [[ $? -eq 0 ]]; then
        echo "Successfully toggled freeze state on $TARGET."
    else
        echo "Failed to toggle freeze state on $TARGET."
    fi

done < "$TARGETS_FILE"

echo "Done."
