#!/bin/bash

# Path to the file containing the list of target machines, users, and passwords
TARGETS_FILE="/home/it3/Desktop/TAPS/updatehostfile/targets.txt"

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

    echo "Removing entries from hosts file on $TARGET with user $USER..."

    # Execute the SSH command using SSHpass to provide the password automatically
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -T "$USER@$TARGET" << EOF
powershell.exe -Command "\$hostsFile = 'C:\\Windows\\System32\\drivers\\etc\\hosts'; \$content = Get-Content -Path \$hostsFile; \$content = \$content | Where-Object { \$_ -notmatch '^127.0.0.1' }; Set-Content -Path \$hostsFile -Value \$content;"
EOF

    if [[ $? -eq 0 ]]; then
        echo "Successfully removed the entries on $TARGET."
    else
        echo "Failed to remove the entries on $TARGET."
    fi
done < "$TARGETS_FILE"

echo "Done."
