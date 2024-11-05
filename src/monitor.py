import sqlite3
import time
import os
import subprocess

database_file = os.path.join(os.path.expanduser("~"), "clipboard.db") 
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

def get_clipboard_content():
    result = subprocess.run(['/usr/bin/xclip', '-o', '-selection', 'clipboard'], 
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode == 0:
        return result.stdout.decode('utf-8')
    else:
        print(f"Error retrieving clipboard content: {result.stderr.decode('utf-8')}")
        return None
        
def monitor_clipboard():
    previous_content = None
    while True:
        content = get_clipboard_content()
        print(f"content: {content}")
        if content != previous_content:
            save_to_db(content)
            previous_content = content
        time.sleep(1)

if __name__ == "__main__":
    connect_to_db()
    monitor_clipboard()