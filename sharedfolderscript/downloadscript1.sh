#!/bin/bash

TARGETS_FILE="/home/it3/Desktop/TAPS/sharedfolderscript/targets.txt"

if [[ ! -f $TARGETS_FILE ]]; then
    echo "Error: $TARGETS_FILE not found. Please create this file with 'IP USER PASSWORD' per line."
    exit 1
fi

while IFS=" " read -r TARGET USER PASSWORD; do
    if [[ -z $TARGET || -z $USER || -z $PASSWORD ]]; then
        continue
    fi

    echo "Connecting to $TARGET as $USER to download file via FTP..."

    # PowerShell script as string
    PS_SCRIPT="
    \$ftpUrl = 'ftp://10.0.0.5/TAPSSharedFolder/test.txt';
    \$user = 'ftpuser';
    \$pass = 'ftpuser';
    \$securePass = ConvertTo-SecureString \$pass -AsPlainText -Force;
    \$cred = New-Object System.Management.Automation.PSCredential(\$user, \$securePass);
    Invoke-WebRequest -Uri \$ftpUrl -OutFile 'C:\\Users\\$USER\\Downloads\\test.txt' -Credential \$cred;
    "

    # Encode PowerShell script to Base64 (UTF-16LE required!)
    ENCODED=$(echo "$PS_SCRIPT" | iconv -f UTF-8 -t UTF-16LE | base64 -w 0)

    # Run encoded command via SSH
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USER@$TARGET" powershell -NoProfile -EncodedCommand "$ENCODED"

    if [[ $? -eq 0 ]]; then
        echo "✅ Successfully downloaded file for $TARGET."
    else
        echo "❌ Failed to download file for $TARGET."
    fi

done < "$TARGETS_FILE"

echo "🎉 Done."
