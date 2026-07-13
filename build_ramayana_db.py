import sqlite3

conn = sqlite3.connect("ramayana.db")
cur = conn.cursor()

cur.execute("""
CREATE TABLE IF NOT EXISTS kandas (
    id INTEGER PRIMARY KEY,
    name TEXT,
    english_name TEXT,
    total_sargas INTEGER
)
""")

cur.execute("""
CREATE TABLE IF NOT EXISTS sargas (
    id INTEGER PRIMARY KEY,
    kanda_id INTEGER,
    title TEXT,
    total_shlokas INTEGER
)
""")

cur.execute("""
CREATE TABLE IF NOT EXISTS shlokas (
    id INTEGER PRIMARY KEY,
    kanda_id INTEGER,
    sarga_id INTEGER,
    shloka_no INTEGER,
    sanskrit TEXT,
    transliteration TEXT,
    translation TEXT,
    explanation TEXT
)
""")

conn.commit()
conn.close()

print("SQLite database created successfully.")
