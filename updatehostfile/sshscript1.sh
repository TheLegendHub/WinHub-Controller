#!/bin/bash

# Prompt for the custom text to add
read -p "Enter the URL that you want to block (e.g., www.example.com): " MY_TEXT

# Path to the file containing the list of target machines and users
TARGETS_FILE="./updatehostfile/targets.txt"

# Check if the targets file exists
if [[ ! -f $TARGETS_FILE ]]; then
    echo "Error: $TARGETS_FILE not found. Please create this file with one target per line."
    exit 1
fi

# Iterate over each line in the list
while IFS=" " read -r TARGET USER; do
    if [[ -z $TARGET || -z $USER ]]; then
        continue  # Skip empty lines or lines without an IP and username
    fi
    
    echo "Updating hosts file on $TARGET with user $USER..."

    # Construct the text to append
    TEXT="127.0.0.1 $MY_TEXT"

    # Execute the SSH command to append the text (using the specific user for each target)
    ssh -T "$USER@$TARGET" << EOF
powershell -Command "Add-Content -Path 'C:\\Windows\\System32\\drivers\\etc\\hosts' -Value '$TEXT'"
EOF

    if [[ $? -eq 0 ]]; then
        echo "Successfully updated $TARGET."
    else
        echo "Failed to update $TARGET."
    fi
done < "$TARGETS_FILE"

echo "Done."
