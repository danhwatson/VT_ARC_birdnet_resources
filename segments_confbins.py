import argparse
import multiprocessing
import os
from multiprocessing import Pool

import numpy as np

# Custom modules (make sure these are available in BirdNET-Analyzer directory)
import audio  
import config as cfg  
import utils 

# Set numpy random seed
np.random.seed(cfg.RANDOM_SEED)

def detectRType(line: str):
    """Detects the type of result file."""
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
    """Read audio and result files."""
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
                data[f.split(".BirdNET.", 1)[0]]["result"] = os.path.join(root, f)

    # Convert to list
    flist = [f for f in data.values() if f["result"]]

    print(f"Found {len(flist)} audio files with valid result file.")

    return flist

def parseFiles(flist: list[dict], max_segments=10):
    """Extracts the segments for all files."""
    species_segments: dict[str, list] = {}

    for f in flist:
        # Paths
        afile = f["audio"]
        rfile = f["result"]

        # Get all segments for result file
        segments = findSegments(afile, rfile)

        # Parse segments by species
        for s in segments:
            if s["species"] not in species_segments:
                species_segments[s["species"]] = []

            species_segments[s["species"]].append(s)

    # Shuffle segments for each species and limit to max_segments
    for s in species_segments:
        np.random.shuffle(species_segments[s])
        species_segments[s] = species_segments[s][:max_segments]

    # Make dict of segments per audio file
    segments: dict[str, list] = {}
    seg_cnt = 0

    for s in species_segments:
        for seg in species_segments[s]:
            if seg["audio"] not in segments:
                segments[seg["audio"]] = []

            segments[seg["audio"]].append(seg)
            seg_cnt += 1

    print(f"Found {seg_cnt} segments in {len(segments)} audio files.")

    # Convert to list
    flist = [tuple(e) for e in segments.items()]

    return flist

def findSegments(afile: str, rfile: str):
    """Extracts the segments for an audio file from the results file."""
    segments: list[dict] = []

    # Open and parse result file
    lines = utils.readLines(rfile)

    # Auto-detect result type
    rtype = detectRType(lines[0])

    # Get start and end times based on rtype
    confidence = 0
    start = end = 0.0
    species = ""

    for i, line in enumerate(lines):
        if rtype == "table" and i > 0:
            # TODO: Use header columns to get the right indices
            d = line.split("\t")
            start = float(d[3])
            end = float(d[4])
            species = d[-4]
            confidence = float(d[-3])

        elif rtype == "audacity":
            d = line.split("\t")
            start = float(d[0])
            end = float(d[1])
            species = d[2].split(", ")[1]
            confidence = float(d[-1])

        elif rtype == "r" and i > 0:
            d = line.split(",")
            start = float(d[1])
            end = float(d[2])
            species = d[4]
            confidence = float(d[5])

        elif rtype == "kaleidoscope" and i > 0:
            d = line.split(",")
            start = float(d[3])
            end = float(d[4]) + start
            species = d[5]
            confidence = float(d[7])

        elif rtype == "csv" and i > 0:
            d = line.split(",")
            start = float(d[0])
            end = float(d[1])
            species = d[3]
            confidence = float(d[4])

        # Check if confidence is within the specified range and label is not "nocall"
        if cfg.MIN_CONFIDENCE <= confidence <= cfg.MAX_CONFIDENCE and species.lower() != "nocall":
            segments.append({"audio": afile, "start": start, "end": end, "species": species, "confidence": confidence})

    return segments

def extractSegments(item: tuple[tuple[str, list[dict]], float, dict[str]]):
    """Saves each segment separately."""
    # Paths and config
    afile = item[0][0]
    segments = item[0][1]
    seg_length = item[1]
    cfg.setConfig(item[2])

    # Status
    print(f"Extracting segments from {afile}")

    try:
        # Open audio file
        sig, _ = audio.openAudioFile(afile, cfg.SAMPLE_RATE)
    except Exception as ex:
        print(f"Error: Cannot open audio file {afile}", flush=True)
        utils.writeErrorLog(ex)
        return

    # Extract segments
    for seg_cnt, seg in enumerate(segments, 1):
        try:
            # Get start and end times
            start = int(seg["start"] * cfg.SAMPLE_RATE)
            end = int(seg["end"] * cfg.SAMPLE_RATE)
            offset = ((seg_length * cfg.SAMPLE_RATE) - (end - start)) // 2
            start = max(0, start - offset)
            end = min(len(sig), end + offset)

            # Make sure segment is long enough
            if end > start:
                # Get segment raw audio from signal
                seg_sig = sig[int(start):int(end)]

                # Make output path
                outpath = os.path.join(cfg.OUTPUT_PATH, seg["species"])
                os.makedirs(outpath, exist_ok=True)

                # Save segment
                seg_name = "{}_{}_{}_{:.1f}s_{:.1f}s.wav".format(
                    format(seg["confidence"], '.3f'), seg_cnt, seg["audio"].rsplit(os.sep, 1)[-1].rsplit(".", 1)[0], seg["start"], seg["end"]
                )
                seg_path = os.path.join(outpath, seg_name)
                audio.saveSignal(seg_sig, seg_path)

        except Exception as ex:
            # Write error log
            print(f"Error: Cannot extract segments from {afile}.", flush=True)
            utils.writeErrorLog(ex)
            return False

    return True

def run_extraction(args, min_conf, max_conf):
    cfg.MIN_CONFIDENCE = min_conf
    cfg.MAX_CONFIDENCE = max_conf
    cfg.FILE_LIST = parseFolders(args.audio, args.results)
    cfg.OUTPUT_PATH = os.path.join(args.o, f"segments_{min_conf}_{max_conf}")
    os.makedirs(cfg.OUTPUT_PATH, exist_ok=True)
    cfg.CPU_THREADS = int(args.threads)
    cfg.FILE_LIST = parseFiles(cfg.FILE_LIST, max(1, int(args.max_segments)))

    flist = [(entry, max(cfg.SIG_LENGTH, float(args.seg_length)), cfg.getConfig()) for entry in cfg.FILE_LIST]

    if cfg.CPU_THREADS < 2:
        for entry in flist:
            extractSegments(entry)
    else:
        with Pool(cfg.CPU_THREADS) as p:
            p.map(extractSegments, flist)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract segments from audio files based on BirdNET detections.")
    parser.add_argument("--audio", default="example/", help="Path to folder containing audio files.")
    parser.add_argument("--results", default="example/", help="Path to folder containing result files.")
    parser.add_argument("--o", default="example/", help="Output folder path for extracted segments.")
    parser.add_argument("--min_conf", type=float, default=0.1, help="Minimum confidence threshold. Values in [0.01, 0.99]. Defaults to 0.1.")
    parser.add_argument("--max_segments", type=int, default=10, help="Number of randomly extracted segments per species.")
    parser.add_argument("--seg_length", type=float, default=3.0, help="Length of extracted segments in seconds. Defaults to 3.0.")
    parser.add_argument("--threads", type=int, default=min(8, max(1, multiprocessing.cpu_count() // 2)), help="Number of CPU threads.")

    args = parser.parse_args()

    confidence_bins = [(0.10, 0.20), (0.21, 0.30), (0.31, 0.40), (0.41, 0.50), (0.51, 0.60), (0.61, 0.70), (0.71, 0.80), (0.81, 0.90), (0.91, 1.0)]

    for min_conf, max_conf in confidence_bins:
        run_extraction(args, min_conf, max_conf)