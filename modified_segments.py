
"""Extract segments from audio files based on BirdNET detections.

Organizes segments by ARU name with species subfolders.
"""
import argparse
import multiprocessing
import os
from multiprocessing import Pool

import numpy as np

import audio
import config as cfg
import utils

# Set numpy random seed
np.random.seed(cfg.RANDOM_SEED)

def detectRType(line: str):
    """Detects the type of result file.

    Args:
        line: First line of text.

    Returns:
        Either "table", "r", "kaleidoscope", "csv" or "audacity".
    """
    if line.lower().startswith("selection"):
        return "table"
    elif line.lower().startswith("filepath"):
        return "r"
    elif line.lower().startswith("indir"):
        return "kaleidoscope"
    elif line.lower().startswith("start (s)"):
        return "csv"
    else:
        return "audacity"

def parseFolders(apath: str, rpath: str, allowed_result_filetypes: list[str] = ["txt", "csv"]) -> list[dict]:
    """Read audio and result files.

    Reads all audio files and BirdNET output inside directory recursively.

    Args:
        apath: Path to search for audio files.
        rpath: Path to search for result files.
        allowed_result_filetypes: List of extensions for the result files.

    Returns:
        A list of {"audio": path_to_audio, "result": path_to_result }.
    """
    data = {}
    apath = apath.replace("/", os.sep).replace("\\", os.sep)
    rpath = rpath.replace("/", os.sep).replace("\\", os.sep)

    # Get all audio files
    for root, _, files in os.walk(apath):
        for f in files:
            if f.rsplit(".", 1)[-1].lower() in cfg.ALLOWED_FILETYPES:
                data[f.rsplit(".", 1)[0]] = {"audio": os.path.join(root, f), "result": ""}

    # Get all result files
    for root, _, files in os.walk(rpath):
        for f in files:
            if f.rsplit(".", 1)[-1] in allowed_result_filetypes and ".BirdNET." in f:
                data[f.split(".BirdNET.")[0]]["result"] = os.path.join(root, f)

    return [v for v in data.values() if v["result"]]

def extractSegments(entry):
    """Extracts segments from an audio file and saves them.

    Args:
        entry: A tuple containing the file list entry and the segment length.
    """
    audio_file, seg_length, config = entry

    # Extract ARU name from the audio file name (e.g., "SMA04922")
    aru_name = os.path.basename(audio_file["audio"]).split("_")[2]

    # Create ARU folder
    aru_folder = os.path.join(cfg.OUTPUT_PATH, aru_name)
    if not os.path.exists(aru_folder):
        os.makedirs(aru_folder)

    # Simulate segment extraction logic (replace with actual extraction logic)
    detected_species = ["speciesA", "speciesB"]  # Replace with actual species detections
    for species in detected_species:
        species_folder = os.path.join(aru_folder, species)
        if not os.path.exists(species_folder):
            os.makedirs(species_folder)

        # Save the extracted segment to the species folder (stub example)
        output_file = os.path.join(species_folder, f"{aru_name}_segment.wav")
        print(f"Saving segment to {output_file}")
        # Replace this with actual saving logic, e.g., audio.extract_segment(audio_file["audio"], output_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract segments from audio files based on BirdNET detections.")
    parser.add_argument("--audio", default="example/", help="Path to folder containing audio files.")
    parser.add_argument("--results", default="example/", help="Path to folder containing result files.")
    parser.add_argument("--o", default="example/", help="Output folder path for extracted segments.")
    parser.add_argument(
        "--min_conf", type=float, default=0.1, help="Minimum confidence threshold. Values in [0.01, 0.99]. Defaults to 0.1."
    )
    parser.add_argument("--max_segments", type=int, default=100, help="Number of randomly extracted segments per species.")
    parser.add_argument(
        "--seg_length", type=float, default=3.0, help="Length of extracted segments in seconds. Defaults to 3.0."
    )
    parser.add_argument("--threads", type=int, default=min(8, max(1, multiprocessing.cpu_count() // 2)), help="Number of CPU threads.")

    args = parser.parse_args()

    # Parse audio and result folders
    cfg.FILE_LIST = parseFolders(args.audio, args.results)

    # Set output folder
    cfg.OUTPUT_PATH = args.o

    # Set number of threads
    cfg.CPU_THREADS = int(args.threads)

    # Set confidence threshold
    cfg.MIN_CONFIDENCE = max(0.01, min(0.99, float(args.min_conf)))

    # Parse file list and make list of segments
    cfg.FILE_LIST = parseFiles(cfg.FILE_LIST, max(1, int(args.max_segments)))

    # Add config items to each file list entry.
    # We have to do this for Windows which does not
    # support fork() and thus each process has to
    # have its own config. USE LINUX!
    flist = [(entry, max(cfg.SIG_LENGTH, float(args.seg_length)), cfg.getConfig()) for entry in cfg.FILE_LIST]

    # Extract segments
    if cfg.CPU_THREADS < 2:
        for entry in flist:
            extractSegments(entry)
    else:
        with Pool(cfg.CPU_THREADS) as p:
            p.map(extractSegments, flist)
