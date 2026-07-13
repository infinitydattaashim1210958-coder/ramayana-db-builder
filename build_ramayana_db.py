import sqlite3

conn = sqlite3.connect("ramayana.db")
cur = conn.cursor()

cur.execute("""
CREATE TABLE IF NOT EXISTS kandas (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    english_name TEXT,
    total_sargas INTEGER
)
""")

cur.execute("""
CREATE TABLE IF NOT EXISTS sargas (
    id INTEGER PRIMARY KEY,
    kanda_id INTEGER,
    title TEXT,
    chapter INTEGER,
    FOREIGN KEY(kanda_id) REFERENCES kandas(id)
)
""")

cur.execute("""
CREATE TABLE IF NOT EXISTS shlokas (
    id INTEGER PRIMARY KEY,
    sarga_id INTEGER,
    sanskrit TEXT,
    pratipada TEXT,
    translation TEXT,
    explanation TEXT,
    FOREIGN KEY(sarga_id) REFERENCES sargas(id)
)
""")

conn.commit()
conn.close()

print("Ramayana SQLite database created successfully.")
