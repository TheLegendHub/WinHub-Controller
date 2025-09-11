import subprocess
import time
from flask import Flask, request, jsonify, send_file, abort
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
#CORS(app)  # Enable CORS for all routes

#COntrolled PC
PC_DETAILS = {
    "32": {"ip": "10.0.249.236", "username": "", "password": ""},
    "31": {"ip": "10.0.162.245", "username": "", "password": ""},
    "30": {"ip": "10.0.180.118", "username": "", "password": ""},
    "29": {"ip": "10.0.180.116", "username": "", "password": ""},
    "28": {"ip": "10.0.173.77", "username": "", "password": ""},
    "27": {"ip": "10.0.3.239", "username": "", "password": ""},
    "26": {"ip": "10.0.168.153", "username": "", "password": ""},    
    "25": {"ip": "10.0.168.112", "username": "", "password": ""},
    "24": {"ip": "10.0.178.7", "username": "", "password": ""},
    "23": {"ip": "10.0.177.245", "username": "", "password": ""},
    "22": {"ip": "10.0.178.21", "username": "", "password": ""},
    "21": {"ip": "10.0.178.23", "username": "", "password": ""},
    "20": {"ip": "10.0.144.153", "username": "", "password": ""},
    "19": {"ip": "10.0.178.75", "username": "", "password": ""},
    "18": {"ip": "10.0.178.78", "username": "", "password": ""},
    "17": {"ip": "10.0.178.85", "username": "", "password": ""},
    "16": {"ip": "10.0.177.238", "username": "", "password": ""},
    "15": {"ip": "10.0.177.243", "username": "", "password": ""},
    "14": {"ip": "10.0.177.250", "username": "", "password": ""},
    "13": {"ip": "10.0.177.253", "username": "", "password": ""},
    "12": {"ip": "10.0.177.252", "username": "", "password": ""},
    "11": {"ip": "10.0.177.254", "username": "", "password": ""},
    "10": {"ip": "10.0.178.0", "username": "", "password": ""},
    "9": {"ip": "10.0.178.4", "username": "", "password": ""},
    "8": {"ip": "10.0.178.128", "username": "", "password": ""},
    "7": {"ip": "10.0.178.109", "username": "", "password": ""},
    "6": {"ip": "10.0.178.114", "username": "", "password": ""},
    "5": {"ip": "10.0.178.94", "username": "", "password": ""},
    "4": {"ip": "10.0.178.130", "username": "", "password": ""},
    "3": {"ip": "10.0.3.221", "username": "", "password": ""},
    "2": {"ip": "10.0.183.114", "username": "", "password": ""},
    "1": {"ip": "10.0.190.16", "username": "", "password": ""}

}
# Allowed IPs
ALLOWED_IPS = ['10.0.249.236','10.0.245.59','10.0.153.48','10.0.153.9','10.0.4.186']
#Target Invidual File
#TARGETS_FILE = "/home/it3/Desktop/TAPS/shutdownscript/targets.txt"
def is_online(ip):
    """Ping the given IP and check if the PC is online"""
    try:
        result = subprocess.run(["ping", "-c", "1", ip], stdout=subprocess.DEVNULL)
        return result.returncode == 0  # If return code is 0, it's online
    except Exception as e:
        return False

def is_ip_in_targets():
    """Check if there is any IP address in the targets.txt file"""
    try:
        with open(TARGETS_FILE, "r") as file:
            lines = file.readlines()
            return any(line.strip() for line in lines)  # Return True if there's at least one non-empty line
    except FileNotFoundError:
        print("Error: targets.txt file not found.")
        return False

@app.before_request
def limit_remote_addr():
    client_ip = request.remote_addr  # Get the client's IP address
    if client_ip not in ALLOWED_IPS:
        abort(403)  # Return a 403 Forbidden response if the IP is not allowed
@app.route('/detections', methods=['GET'])
def get_detections():
    try:
        with open("/home/it3/Desktop/TAPS/AIDetectionModel/detection_results.txt", "r") as f:
            lines = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        return jsonify({"error": "No detection results found."}), 404

    # Format as JSON response
    detections = {}
    for line in lines:
        if ":" in line:
            camera, count = line.split(":", 1)
            detections[camera.strip()] = count.strip()

    return jsonify(detections)

@app.route('/restart', methods=['GET'])
def restart_services():
    wrapper_script = "/home/it3/Desktop/TAPS/ActivateServer/restart.sh"
    subprocess.Popen(['bash', wrapper_script])
    return jsonify({"message": "Restart sequence started"}), 200

@app.route('/execute', methods=['GET'])
def execute_choice():
    # Get the choice parameter from the request
    choice = request.args.get('choice')
    pc_number = request.args.get('pc')
    indivi_pc= request.args.get('indv')
    website= request.args.get('website')
    file= request.args.get('file')
    if not choice:
        return jsonify({"error": "No choice provided"}), 400
    if indivi_pc == '1':
        if pc_number in PC_DETAILS:
            ip = PC_DETAILS[pc_number]["ip"]
            username = PC_DETAILS[pc_number]["username"]
            password = PC_DETAILS[pc_number]["password"]
            if choice == "20": # Shutdown action
                 TARGETS_FILE = "/home/it3/Desktop/TAPS/freezecomputer/targets.txt"
                 with open("/home/it3/Desktop/TAPS/freezecomputer/targets.txt", "w") as f:
                      f.write(f"{ip} {username} {password}\n")
                 subprocess.run(["/home/it3/Desktop/TAPS/freezecomputer/freeze.sh"])  # Execute the script 
                 with open(TARGETS_FILE, "w") as file:
                      file.truncate(0)  # Erase contents of targets.txt
                      return f"Shutdown command sent to {ip}"

            if choice == "30":
                 status = "Online" if is_online(ip) else "Offline"
                 return jsonify({"pc": pc_number, "status": status})
            if choice == "5":  # Shutdown action
                 TARGETS_FILE = "/home/it3/Desktop/TAPS/shutdownscript/targets.txt"
                 with open("/home/it3/Desktop/TAPS/shutdownscript/targets.txt", "w") as f:
                      f.write(f"{ip} {username} {password}\n")
                 subprocess.run(["/home/it3/Desktop/TAPS/shutdownscript/shutdownscript.sh"])  # Execute the script 
                 with open(TARGETS_FILE, "w") as file:
                      file.truncate(0)  # Erase contents of targets.txt
                      return f"Shutdown command sent to {ip}"
            return "Invalid action", 400
        else:
            return "PC not found", 404


    # Prepare the result to return to the user
    result = ""

    if choice == '1':
        # Run the Python script without capturing the result
        run_command("python3 ./checkup/checkup.py")
        #time.sleep(60)  # Delay for 1 minute
        result += "\n\nContent of the text file:\n"
        result += read_text_file("/home/it3/Desktop/TAPS/checkup/pc_status_log.txt")  # Path to your log file

        # After the script finishes, return the file as a response
        return send_file(
            '/home/it3/Desktop/TAPS/checkup/pc_status_log.txt',  # Path to your log file
            as_attachment=True,  # This forces the file to be downloaded
            download_name='pc_status_log.txt'  # The name of the file when downloaded
        )
    elif choice == '2':
        result = run_command("./updatehostfile/sshscript.sh")
    elif choice == '3':
        result = run_command("sudo tail -f /var/log/squid/access.log")
    elif choice == '4':
        result = run_command("ping -c 4 8.8.8.8")
    elif choice == '5':
        result = run_command("./shutdownscript/shutdownscript.sh")
    elif choice == '6':
        result = run_command("/home/it3/Desktop/TAPS/displaymessage/displaymessage.sh")
    elif choice == '7':
        result = run_command("/home/it3/Desktop/TAPS/shutdownall/shutdownscript.sh")
    elif choice == '9':
        result = run_command("/home/it3/Desktop/TAPS/shutdownallComputerLab/shutdownscript.sh")
    elif choice == '10':
        result = run_command_arg("/home/it3/Desktop/TAPS/updatehostfileUserInput/updhostfile.sh",[website])
    elif choice == '11':
        result = run_command("//home/it3/Desktop/TAPS/restorehostfile/restorehostfile.sh")
    elif choice == '12':
        result = run_command_arg("/home/it3/Desktop/TAPS/removeURL/removeURL.sh",[website])
    elif choice == '13':
        result = run_command_arg("/home/it3/Desktop/TAPS/sharedfolderscript/downloadscript.sh",[file])
    elif choice == '8':
        return jsonify({"message": "Exiting..."}), 200
    else:
        return jsonify({"error": "Invalid choice. Please select a valid option."}), 400

    return jsonify({"result": result})
def run_command_arg(command, args):
        """Runs a shell command with the given arguments."""
        try:
            result = subprocess.run(
                [command] + args,  # Combine the command and arguments
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            return result.stdout
        except subprocess.CalledProcessError as e:
            return f"Error: {e.stderr}"

def run_command(command):
    try:
        # Execute the command without capturing the result (just run it)
        subprocess.check_call(command, shell=True)  # Using check_call to run the command without capturing output
    except subprocess.CalledProcessError as e:
        return f"Error occurred: {str(e)}"

def read_text_file(file_path):
    try:
        with open(file_path, 'r') as file:
            return file.read()  # Read the file content and return it
    except Exception as e:
        return f"Error reading file: {str(e)}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
