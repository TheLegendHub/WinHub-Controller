import os
import subprocess
from datetime import datetime

# Dictionary of labeled PCs
pc_dict = {
    "Bashar PC": "10.0.249.236",
    "Grade 1B" : "10.0.0.234",
    "Grade 1C" : "10.0.0.233",
    "Grade 2A" : "10.0.0.224",
    "Grade 2B" : "10.0.0.230",
    "Grade 3A": "10.0.10.109",
    "Grade 3B": "10.0.245.122",
    "Grade 4A": "10.0.240.121",
    "Grade 4B": "10.0.10.106",
    "Grade 4C": "10.0.0.214",
    "Grade 5A": "10.0.10.112",
    "Grade 5B": "10.0.0.216",
    "Grade 5D": "10.0.0.247",
    "Grade 5E": "10.0.0.248",
    "Grade 6B": "10.0.1.10",
    "Grade 6E": "10.0.0.240",
    "Grade 6D": "10.0.0.239",
    "Grade 7A": "10.0.17.1",
    "Grade 7B": "10.0.11.102",
    "Grade 7E": "10.0.182.238",
    "Grade 7D": "10.0.0.242",
    "Grade 8A": "10.0.220.222",
    "Grade 8B": "10.0.196.4",
    "Grade 8D": "10.0.0.236",
    "Grade 8E": "10.0.224.142",
    "Grade 9B": "10.0.0.255",
    "Grade 9D": "10.0.0.250",
    "Grade 10A": "10.0.0.252",
    "Grade 10B": "10.0.214.90",
    "Grade 10E": "10.0.10.218",
    "Grade 10D": "10.0.0.218",
    "Grade 11A": "10.0.1.2",
    "Grade 11E": "10.0.0.219",
    "Grade 11D": "10.0.11.105",
    "Grade 12A": "10.0.227.90",
    "Grade 12B": "10.0.1.1",
    "Grade 12E": "10.0.0.222",
    "Grade 12D": "10.0.0.217",
    "Art Room-Gs" : "10.0.0.254"
}

# Function to ping a PC
def ping_pc(pc):
    try:
        # Run the ping command
        result = subprocess.run(
            ["ping", "-c", "1", "-w", "1", pc] if os.name != "nt" else ["ping", "-n", "1", "-w", "1000", pc],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        return result.returncode == 0  # True if ping is successful
    except Exception as e:
        return False  # If there's an error, assume it's offline

# Path to the log file
log_file_path = "./checkup/pc_status_log.txt"

# Ensure the directory exists
log_dir = os.path.dirname(log_file_path)
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

# Live check loop
with open(log_file_path, "a") as log_file:
    current_time = datetime.now()
    log_file.write(f"Checkup started at {current_time}\n")
    print(f"Checkup started at {current_time}\n")
    
    online_pcs = []
    offline_pcs = []

    for label, ip in pc_dict.items():
        if ping_pc(ip):
            online_pcs.append(f"{label} ({ip})")
        else:
            offline_pcs.append(f"{label} ({ip})")

    # Log and display Online PCs
    if online_pcs:
        log_file.write("Online PCs:\n")
        print("Online PCs:")
        for pc in online_pcs:
            log_file.write(f"  - {pc}\n")
            print(f"  - {pc}")
    else:
        log_file.write("No PCs are online.\n")
        print("No PCs are online.")

    # Log and display Offline PCs
    if offline_pcs:
        log_file.write("\nOffline PCs:\n")
        print("\nOffline PCs:")
        for pc in offline_pcs:
            log_file.write(f"  - {pc}\n")
            print(f"  - {pc}")
    else:
        log_file.write("\nNo PCs are offline.\n")
        print("\nNo PCs are offline.")
    
    log_file.write("\n")
    print("\nCheck completed.")
