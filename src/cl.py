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
    print("\nLast Clipboard Entries:\n" + "-" * 30)
    for idx, entry in enumerate(entries, start=1):
        print(f"{entry[2]}")
        print("-" * 30)
    
    return entries

def get_last_entry():
    cursor.execute("SELECT * FROM history ORDER BY id DESC LIMIT 1")
    entry = cursor.fetchone()
    print("\nLast Clipboard Entries:\n" + "-" * 30)
    print(entry[2])
    print("-" * 30)
    return entry

def main():
    parser = argparse.ArgumentParser(description="Clipboard manager")
    parser.add_argument("-n", type=int, help="Number of last entries to display")
    args = parser.parse_args()
    if args.n:
        get_n_last_entries(args.n)
    else:
        get_last_entry()

if __name__ == "__main__":
    main()
