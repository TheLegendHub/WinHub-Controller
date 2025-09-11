#!/bin/bash

# Path to the file containing the list of target machines, users, and passwords
TARGETS_FILE="/home/it3/Desktop/TAPS/freezecomputer/targets.txt"

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

    echo "Freezing $TARGET by killing explorer.exe with user $USER..."

    # Execute the SSH command to freeze the machine by killing explorer.exe
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -T "$USER@$TARGET" << EOF
    taskkill /F /IM explorer.exe
EOF

    if [[ $? -eq 0 ]]; then
        echo "Successfully froze $TARGET."
    else
        echo "Failed to freeze $TARGET."
    fi

done < "$TARGETS_FILE"

echo "Done."
