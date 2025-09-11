#!/bin/bash

while true; do
    # Display the menu
    echo "Choose an option:"
    echo "1. Check Online/Offline PC"
    echo "2. Block Websites in Computer Labs"
    echo "3. Monitor a PC"
    echo "4. Check Internet Connection"
    echo "5. Shutting down remote PC's"
    echo "6. Send Message to Remote PCs"
    echo "7. Shutdown all PC in Boys Section Remote PCs"
    echo "8. Setting Password for Boys Computer Lab PC's. to student.."
    echo "9. Setting firewall for Boys Computer Lab PC's."
    echo "10. Unblock Websites based on URL"
    echo "11. Exit"

    # Read the user's choice
    read -p "Enter your choice (1-11): " choice

    # Execute based on the user's input
    case $choice in
        1)
            echo "Running checkup.py..."
            python3 ./checkup/checkup.py
            ;;
        2)
            echo "Running sshscript.sh..."
            ./updatehostfile/sshscript.sh
            ;;
        3)
            echo "Viewing Squid access log..."
            sudo tail -f /var/log/squid/access.log
            ;;
        4)
            echo "Checking Internet connection..."
            ping 8.8.8.8
            ;;
        5)
            echo "Shutting Down Remote PC's..."
            ./shutdownscript/shutdownscript.sh
            ;;
        6)
            echo "Sending messages to remote PCs..."
            /home/it3/Desktop/TAPS/displaymessage/displaymessage.sh
            ;;
        7)
            echo "Shutting down Computer Lab PC's..."
            /home/it3/Desktop/TAPS/shutdownallComputerLab/shutdownscript.sh
            ;;
        8)
            echo "Setting Password for Boys Computer Lab PC's. to student.."
            /home/it3/Desktop/TAPS/setpassword/setpassword.sh
            ;;
        9)
            echo "Setting firewall for Boys Computer Lab PC's"
            /home/it3/Desktop/TAPS/checkup/setfirewall.sh
            ;;
        10)
            echo "Setting firewall for Boys Computer Lab PC's"
            /home/it3/Desktop/TAPS/removeURL/removeURL.sh
            ;;
        11)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a number between 1 and 8."
            ;;
    esac

    # Pause before showing the menu again
    echo ""
    read -p "Press Enter to continue..." 
    clear
done
