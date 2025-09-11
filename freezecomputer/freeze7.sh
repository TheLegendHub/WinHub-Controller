#!/bin/bash

TARGETS_FILE="/home/it3/Desktop/TAPS/freezecomputer/targets.txt"

# Ensure the file exists before processing
if [[ ! -f "$TARGETS_FILE" ]]; then
    echo "Error: Target file $TARGETS_FILE not found!"
    exit 1
fi

# Iterate over each line in the list
while IFS=" " read -r TARGET USER PASSWORD; do
    if [[ -z $TARGET || -z $USER || -z $PASSWORD ]]; then
        continue  # Skip empty lines or malformed lines
    fi

    echo "Toggling freeze state on $TARGET with user $USER..."

    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -T "$USER@$TARGET" << 'EOF'
    powershell -Command "& {
        $process = Get-Process explorer -ErrorAction SilentlyContinue
        if ($process) {
            Write-Output 'Explorer is running. Terminating...'
            Stop-Process -Name explorer -Force
        } else {
            Write-Output 'Explorer is not running. Restarting...'
            Start-Process explorer
        }
    }"
EOF

    if [[ $? -eq 0 ]]; then
        echo "Successfully toggled freeze state on $TARGET."
    else
        echo "Failed to toggle freeze state on $TARGET."
    fi

done < "$TARGETS_FILE"

echo "Done."
