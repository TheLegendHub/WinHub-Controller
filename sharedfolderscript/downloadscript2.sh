#!/bin/bash

TARGETS_FILE="/home/it3/Desktop/TAPS/sharedfolderscript/targets.txt"

# Check for argument
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

FILENAME="$1"

# Check if the targets file exists
if [[ ! -f $TARGETS_FILE ]]; then
    echo "Error: $TARGETS_FILE not found. Please create this file with 'IP USER PASSWORD' per line."
    exit 1
fi

while IFS=" " read -r TARGET USER PASSWORD; do
    if [[ -z $TARGET || -z $USER || -z $PASSWORD ]]; then
        continue
    fi

    echo "Connecting to $TARGET as $USER to download $FILENAME via FTP..."

    # PowerShell script with variable filename
    PS_SCRIPT="
    \$ftpUrl = 'ftp://10.0.0.5/TAPSSharedFolder/$FILENAME';
    \$user = 'ftpuser';
    \$pass = 'ftpuser';
    \$securePass = ConvertTo-SecureString \$pass -AsPlainText -Force;
    \$cred = New-Object System.Management.Automation.PSCredential(\$user, \$securePass);
    Invoke-WebRequest -Uri \$ftpUrl -OutFile 'C:\\Users\\BS-Lab-PC01\\Desktop\\$FILENAME' -Credential \$cred;
    "

    # Encode PowerShell script to Base64
    ENCODED=$(echo "$PS_SCRIPT" | iconv -f UTF-8 -t UTF-16LE | base64 -w 0)

    # Send it via SSH and run it
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$TARGET" powershell -NoProfile -EncodedCommand "$ENCODED"

    if [[ $? -eq 0 ]]; then
        echo "✅ Successfully downloaded $FILENAME for $TARGET."
    else
        echo "❌ Failed to download $FILENAME for $TARGET."
    fi

done < "$TARGETS_FILE"

echo "🎉 All done!"
