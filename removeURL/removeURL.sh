#!/bin/bash

# Get the URL from the argument
MY_TEXT=$1

TARGETS_FILE="/home/it3/Desktop/TAPS/removeURL/targets.txt"

if [[ ! -f $TARGETS_FILE ]]; then
    echo "Error: $TARGETS_FILE not found."
    exit 1
fi

while IFS=" " read -r TARGET USER PASSWORD; do
    if [[ -z $TARGET || -z $USER || -z $PASSWORD ]]; then
        continue
    fi

    echo "Removing $MY_TEXT from hosts file on $TARGET..."

    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -T "$USER@$TARGET" << EOF
powershell -Command "\$hostsPath = 'C:\\Windows\\System32\\drivers\\etc\\hosts'; \$lines = Get-Content \$hostsPath | Where-Object { \$_ -notmatch '^127\\.0\\.0\\.1\\s+$MY_TEXT\$' }; \$lines | Out-File -FilePath \$hostsPath -Encoding ASCII"
EOF


    if [[ $? -eq 0 ]]; then
        echo "Successfully updated $TARGET."
    else
        echo "Failed to update $TARGET."
    fi
done < "$TARGETS_FILE"

echo "Done."
