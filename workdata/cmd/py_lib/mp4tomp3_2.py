#!/usr/bin/env python3
import sys
import subprocess

def main():
    if len(sys.argv) != 3:
        print("使い方: mp4tomp3.py 入力.mp4 出力.mp3")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    # ビットレートを 96kbps に設定（軽量）
    cmd = [
        "ffmpeg",
        "-i", input_file,
        "-vn",
        "-ar", "44100",
        "-b:a", "32k",
        "-acodec", "mp3",
        output_file
    ]

    subprocess.run(cmd)

if __name__ == "__main__":
    main()

