#!/bin/bash

# Path to the file containing the list of target machines with IP, username, and password
TARGETS_FILE="/home/it3/Desktop/TAPS/displaymessage/targets.txt"

# Prompt for the custom message to display
read -p "Enter the message you want to send to the remote PCs: " MESSAGE

# Ensure sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "Error: sshpass is not installed. Install it using your package manager (e.g., apt, yum, brew)."
    exit 1
fi

# Check if the targets file exists
if [[ ! -f $TARGETS_FILE ]]; then
    echo "Error: $TARGETS_FILE not found. Please create this file with one entry per line: IP USER PASSWORD"
    exit 1
fi

# Iterate over each line in the list
while IFS=" " read -r TARGET USER PASS; do
    if [[ -z $TARGET || -z $USER || -z $PASS ]]; then
        continue  # Skip empty lines or improperly formatted lines
    fi

    echo "Sending message to $TARGET with user $USER..."

    # Execute the SSH command to display the message
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -T "$USER@$TARGET" << EOF
msg * "$MESSAGE"
EOF

    if [[ $? -eq 0 ]]; then
        echo "Successfully sent message to $TARGET."
    else
        echo "Failed to send message to $TARGET."
    fi
done < "$TARGETS_FILE"

echo "Done."
