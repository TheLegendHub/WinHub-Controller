#!/bin/bash 

# Path to the file containing the list of target machines and users
TARGETS_FILE="./targets.txt"

# Prompt for the custom message to display
read -p "Enter the message you want to send to the remote PCs: " MESSAGE

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
    
    echo "Sending message to $TARGET with user $USER..."

    # Execute the SSH command to display the message
    ssh -T "$USER@$TARGET" << EOF
msg * "$MESSAGE"
EOF

    if [[ $? -eq 0 ]]; then
        echo "Successfully sent message to $TARGET."
    else
        echo "Failed to send message to $TARGET."
    fi
done < "$TARGETS_FILE"

echo "Done."
