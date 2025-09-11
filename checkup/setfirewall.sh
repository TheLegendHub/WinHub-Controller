#!/bin/bash 

# Path to the file containing the list of target machines, users, and passwords
TARGETS_FILE="/home/it3/Desktop/TAPS/setpassword/targets.txt"


# Iterate over each line in the list
while IFS=" " read -r TARGET USER PASSWORD; do
    if [[ -z $TARGET || -z $USER || -z $PASSWORD ]]; then
        continue  # Skip empty lines or malformed lines
    fi
    
    echo "Setting User $TARGET with user $USER..."

    # Execute the SSH command to shutdown the machine using sshpass for password authentication
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -T "$USER@$TARGET" << EOF
netsh advfirewall firewall set rule name="File and Printer Sharing (Echo Request - ICMPv4-In)" new enable=yes
EOF

    if [[ $? -eq 0 ]]; then
        echo "Successfully User set $TARGET."
    else
        echo "Failed to set user $TARGET."
    fi

done < "$TARGETS_FILE"

echo "Done."
