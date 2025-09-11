#!/bin/bash

# Get the URL from the argument
MY_TEXT=$1

# Path to the file containing the list of target machines, users, and passwords
TARGETS_FILE="/home/it3/Desktop/TAPS/updatehostfileUserInput/targets.txt"

# Check if the targets file exists
if [[ ! -f $TARGETS_FILE ]]; then
    echo "Error: $TARGETS_FILE not found. Please create this file with one target per line."
    exit 1
fi

# Iterate over each line in the list
while IFS=" " read -r TARGET USER PASSWORD; do
    if [[ -z $TARGET || -z $USER || -z $PASSWORD ]]; then
        continue  # Skip empty lines or lines missing an IP, username, or password
    fi

    echo "Updating hosts file on $TARGET with user $USER..."

    # Construct the text to append
    TEXT="127.0.0.1 $MY_TEXT"

    # Execute the SSH command using SSHpass to provide the password automatically
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -T "$USER@$TARGET" << EOF
powershell -Command "Add-Content -Path 'C:\\Windows\\System32\\drivers\\etc\\hosts' -Value '$TEXT'"
EOF

    if [[ $? -eq 0 ]]; then
        echo "Successfully updated $TARGET."
    else
        echo "Failed to update $TARGET."
    fi
done < "$TARGETS_FILE"

echo "Done."
