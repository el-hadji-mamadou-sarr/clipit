import sqlite3
import time
import pyperclip
import subprocess
import argparse



database_file = "clipboard.db"
conn = sqlite3.connect(database_file)
cursor = conn.cursor()

def connect_to_db():
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT,
    content TEXT)
                """)
    conn.commit()

def save_to_db(content):
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    cursor.execute("insert into history (timestamp, content) values(?,?)", (timestamp, content))
    conn.commit()

def get_n_last_entries(n: int):
    cursor.execute("select * from history order by id desc limit ?", (n,))
    entries = cursor.fetchall()
    return entries


def monitor_clipboard():
    previous_content = None
    while True:
        content = pyperclip.paste()
        if content != previous_content:
            save_to_db(content)
            previous_content = content
        time.sleep(1)

if __name__ == "__main__":
    connect_to_db()
    monitor_clipboard()