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
    # Detects the type of result file.
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
    # Read audio and result files.
    data = {}
    apath = apath.replace("/", os.sep).replace("\\\\", os.sep)
    rpath = rpath.replace("/", os.sep).replace("\\\\", os.sep)

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

    return [v for v in data.values() if v["audio"] and v["result"]]

def parseFiles(filelist: list[dict], max_segments: int) -> list[dict]:
    # Parses file list and makes list of segments.
    segment_list = []
    for f in filelist:
        with open(f["result"], "r") as rfile:
            lines = rfile.readlines()
            rtype = detectRType(lines[0])
            segments = []
            for line in lines[1:]:
                try:
                    if rtype == "table":
                        parts = line.split("\t")
                        start = float(parts[3])
                        end = float(parts[4])
                        species = parts[10]
                        confidence = float(parts[11])
                    elif rtype == "csv":
                        parts = line.split(",")
                        start = float(parts[0])
                        end = float(parts[1])
                        species = parts[7]
                        confidence = float(parts[8])
                    else:
                        continue

                    if confidence >= cfg.MIN_CONFIDENCE and (cfg.SPECIES is None or species == cfg.SPECIES):
                        segments.append((start, end, species, confidence))
                except Exception as e:
                    continue

            if len(segments) > max_segments:
                segments = np.random.choice(segments, max_segments, replace=False).tolist()

            f["segments"] = segments
            segment_list.append(f)

    return segment_list

def extractSegments(flist_entry: tuple):
    # Extracts segments from audio files.
    f, length, config = flist_entry
    audio.extractSegments(f, length, config)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--audio", default="example/", help="Path to folder containing audio files.")
    parser.add_argument("--results", default="example/", help="Path to folder containing result files.")
    parser.add_argument("--o", default="example/", help="Output folder path for extracted segments.")
    parser.add_argument("--min_conf", type=float, default=0.1, help="Minimum confidence threshold. Values in [0.01, 0.99]. Defaults to 0.1.")
    parser.add_argument("--max_segments", type=int, default=100, help="Number of randomly extracted segments per species.")
    parser.add_argument("--seg_length", type=float, default=3.0, help="Length of extracted segments in seconds. Defaults to 3.0.")
    parser.add_argument("--threads", type=int, default=min(8, max(1, multiprocessing.cpu_count() // 2)), help="Number of CPU threads.")
    parser.add_argument("--species", default=None, help="Filter segments by species.")

    args = parser.parse_args()

    # Set species filter
    cfg.SPECIES = args.species

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
    flist = [(entry, max(cfg.SIG_LENGTH, float(args.seg_length)), cfg.getConfig()) for entry in cfg.FILE_LIST]

    # Extract segments
    if cfg.CPU_THREADS < 2:
        for entry in flist:
            extractSegments(entry)
    else:
        with Pool(cfg.CPU_THREADS) as p:
            p.map(extractSegments, flist)
