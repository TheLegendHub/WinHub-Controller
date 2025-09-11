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
    
    echo "Shutting down $TARGET with user $USER..."

    # Execute the SSH command to shutdown the machine using sshpass for password authentication
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -T "$USER@$TARGET" << EOF
shutdown /s /f /t 0
EOF

    if [[ $? -eq 0 ]]; then
        echo "Successfully shut down $TARGET."
    else
        echo "Failed to shut down $TARGET."
    fi

done < "$TARGETS_FILE"

echo "Done."
