# -*- coding: utf-8 -*-
import argparse
import subprocess
import os
import re


def get_file_size_mb(path):
    size_bytes = os.path.getsize(path)
    return round(size_bytes / (1024 * 1024), 2)

def get_video_duration(path):
    result = subprocess.run(
        ['ffprobe', '-v', 'error', '-show_entries', 'format=duration',
         '-of', 'default=noprint_wrappers=1:nokey=1', path],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    try:
        return float(result.stdout.strip())
    except ValueError:
        return None

def parse_ffmpeg_time(line):
    match = re.search(r'time=(\d+):(\d+):(\d+)\.(\d+)', line)
    if match:
        h, m, s, ms = map(int, match.groups())
        return h * 3600 + m * 60 + s + ms / 100
    return None

def compress_to_720p(input_path, output_dir):
    filename = os.path.basename(input_path)
    name, ext = os.path.splitext(filename)
    output_path = os.path.join(output_dir, f"{name}_720p{ext}")

    original_size = get_file_size_mb(input_path)
    print(f"Input file: {filename}")
    print(f"Original size: {original_size} MB")

    duration = get_video_duration(input_path)
    if duration is None:
        print("Failed to get video duration.")
        return

    command = [
        'ffmpeg',
        '-i', input_path,
        '-vf', 'scale=-2:720',
        '-c:v', 'libx264',
        '-crf', '23',
        '-preset', 'medium',
        '-c:a', 'aac',
        '-threads', '3',           # マルチスレッド
        '-b:a', '96k',
        '-b:v', '1500k',

        output_path
    ]

    process = subprocess.Popen(command, stderr=subprocess.PIPE, text=True)

    for line in process.stderr:
        time_sec = parse_ffmpeg_time(line)
        if time_sec is not None and duration > 0:
            percent = min(100, round((time_sec / duration) * 100, 1))
            print(f"Progress: {percent}%")

    process.wait()

    if os.path.exists(output_path):
        compressed_size = get_file_size_mb(output_path)
        print(f"Output file: {os.path.basename(output_path)}")
        print(f"Compressed size: {compressed_size} MB")
        print(f"Compression ratio: {round((compressed_size / original_size) * 100, 1)}%")
    else:
        print("Compression failed.")

def main():
    parser = argparse.ArgumentParser(description="Compress MP4 videos to 720p with progress display.")
    parser.add_argument('videos', nargs='+', help='Paths to input video files')
    parser.add_argument('--output-dir', default='compressed_videos', help='Directory to save compressed videos')
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    for i, video in enumerate(args.videos, 1):
        print(f"\nProcessing file {i} of {len(args.videos)}")
        compress_to_720p(video, args.output_dir)

if __name__ == '__main__':
    main()

