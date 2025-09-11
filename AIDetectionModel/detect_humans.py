from ultralytics import YOLO
import cv2
import numpy as np
import subprocess
import os
import time
import shutil

# === CONFIGURATION ===
NVR_IP = ""
USERNAME = ""
PASSWORD = ""
MAX_CAMERAS = 26
OUTPUT_DIR = "/home/it3/Desktop/TAPS/AIDetectionModel/outputs"
RESULTS_FILE = "/home/it3/Desktop/TAPS/AIDetectionModel/detection_results.txt"

CAMERA_NAMES = [
    "Elevator Staircase View",
    "Indoor Main Staircase Main Building Entrance - Boys Section",
    "Outside Boys Reception",
    "KG Playground",
    "KG Hallway",
    "KG Hallway View 2",
    "Boys Playground View 3",
    "Outside Canteen Gate",
    "Basketball Court Yard",
    "Boys Section Hall Way View",
    "Outside Restroom Junior View",
    "KG Food Court",
    "Midway Main Staircase View 2",
    "Volleyball View",
    "KG Playground View 2",
    "Grade 12A",
    "KG Outside Restroom View_NVR 3",
    "Canteen Indoor View - Boys Section",
    "Computer Lab Staircase View - Boys Section",
    "Canteen Indoor View 2 - Boys Section",
    "Bus Exit Gate View 1",
    "Boys Playground View 4",
    "Restroom Outside Senior Section",
    "Canteen Outdoor View",
    "KG Playground View 3",
    "Bus Exit View 2"
]

# Create output directory
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Load YOLOv8 model
model = YOLO("yolov8n.pt")

# Check FFmpeg availability
if not shutil.which("ffmpeg"):
    raise RuntimeError("FFmpeg not found. Please install FFmpeg before running this script.")

# Pixel formats to try
PIX_FMTS = ["rgb24", "yuv420p", "bgr24"]

def read_frame(rtsp_url, width=640, height=384):
    """
    Read a single frame from RTSP using FFmpeg.
    Tries multiple pix_fmt options to avoid grey frames.
    Returns a writable BGR frame or None if failed.
    """
    for pix_fmt in PIX_FMTS:
        ffmpeg_cmd = [
            "ffmpeg",
            "-rtsp_transport", "tcp",
            "-i", rtsp_url,
            "-f", "rawvideo",
            "-pix_fmt", pix_fmt,
            "-vf", f"scale={width}:{height}",
            "pipe:1"
        ]
        try:
            pipe = subprocess.Popen(ffmpeg_cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, bufsize=10**8)
            frame_size = width * height * 3
            raw_frame = pipe.stdout.read(frame_size)
            pipe.terminate()
            if len(raw_frame) != frame_size:
                continue

            frame = np.frombuffer(raw_frame, np.uint8).reshape((height, width, 3))

            # Convert YUV formats to BGR if needed
            if pix_fmt == "rgb24":
                frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR).copy()
            elif pix_fmt == "yuv420p":
                frame = cv2.cvtColor(frame, cv2.COLOR_YUV2BGR_I420).copy()
            else:
                frame = frame.copy()

            # Check if frame is valid
            if not is_grey_frame(frame):
                return frame
        except:
            continue
    return None

def is_grey_frame(frame, threshold=5):
    """
    Check if frame is mostly grey (no meaningful content)
    """
    if frame is None:
        return True
    diff = frame.max(axis=2) - frame.min(axis=2)
    return np.mean(diff) < threshold

# Open result file
with open(RESULTS_FILE, "w") as result_log:

    for cam_id in range(1, MAX_CAMERAS + 1):
        cam_name = CAMERA_NAMES[cam_id - 1]
        main_stream = f"rtsp://{USERNAME}:{PASSWORD}@{NVR_IP}:554/Streaming/Channels/{cam_id:02d}01/"
        sub_stream  = f"rtsp://{USERNAME}:{PASSWORD}@{NVR_IP}:554/Streaming/Channels/{cam_id:02d}02/"

        print(f"📷 Checking Camera {cam_id}: {cam_name} → {main_stream}")

        # Try main stream first
        frame = read_frame(main_stream)

        # If frame is invalid or grey, fallback to sub-stream
        if frame is None:
            print(f"⚠ Main stream invalid/grey, trying sub-stream...")
            frame = read_frame(sub_stream)

        if frame is None:
            print(f"❌ Camera {cam_id} ({cam_name}) returned invalid frame.\n")
            result_log.write(f"{cam_name}: Person 0 (offline or no frame)\n")
            continue

        print(f"✅ Camera {cam_id} is online. Running detection...")

        # Run YOLO detection
        results = model(frame)
        boxes = results[0].boxes.data
        person_detections = [box for box in boxes if int(box[-1]) == 0]
        person_count = len(person_detections)

        # Draw detections
        for box in person_detections:
            x1, y1, x2, y2, score, class_id = box
            x1, y1, x2, y2 = map(int, [x1, y1, x2, y2])
            cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
            cv2.putText(frame, f"Person {score:.2f}", (x1, y1 - 10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

        # Annotate frame
        cv2.putText(frame, f"{cam_name} | Persons: {person_count}", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)

        # Save final processed frame
        sanitized_name = cam_name.replace(" ", "_").replace("/", "-")
        output_path = os.path.join(OUTPUT_DIR, f"{sanitized_name}.jpg")
        cv2.imwrite(output_path, frame)

        # Write results to log
        result_log.write(f"{cam_name}: Person {person_count}\n")
        print(f"👤 {cam_name}: Person {person_count}")
        print(f"💾 Saved to {output_path}\n")

print(f"✅ Finished checking all cameras. Results saved to '{RESULTS_FILE}'.")
