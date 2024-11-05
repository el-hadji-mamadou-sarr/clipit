#!/usr/bin/env python3
import argparse
import sqlite3
import os

database_file = os.path.join(os.path.expanduser("~"), "clipboard.db") 
conn = sqlite3.connect(database_file)
cursor = conn.cursor()

def get_n_last_entries(n: int):
    cursor.execute("SELECT * FROM history ORDER BY id DESC LIMIT ?", (n,))
    entries = cursor.fetchall()
    for entry in entries:
        print(entry[2])
    return entries

def main():
    parser = argparse.ArgumentParser(description="Clipboard manager")
    parser.add_argument("-n", type=int, help="Number of last entries to display")
    args = parser.parse_args()
    if args.n:
        get_n_last_entries(args.n)
    else:
        get_n_last_entries(1)

if __name__ == "__main__":
    main()
