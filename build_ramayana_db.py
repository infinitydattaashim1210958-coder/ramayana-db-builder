import requests
import sqlite3
import time
import os

BASE_URL = "https://ramayana.hindbiswas.com/api"
DB_NAME = "ramayana.db"


def api_get(url, retries=3):
    for attempt in range(retries):
        try:
            r = requests.get(url, timeout=30)

            if r.status_code == 200:
                return r.json()

            print("HTTP Error:", r.status_code)

        except Exception as e:
            print("Retry:", attempt + 1, e)

        time.sleep(2)

    return None


def create_db():

    conn = sqlite3.connect(DB_NAME)
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
        chapter INTEGER
    )
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS shlokas (
        id INTEGER PRIMARY KEY,
        sarga_id INTEGER,
        sanskrit TEXT,
        pratipada TEXT,
        translation TEXT,
        explanation TEXT
    )
    """)

    conn.commit()

    return conn



def insert_kanda(conn, k):

    conn.execute("""
    INSERT OR REPLACE INTO kandas
    VALUES (?,?,?,?)
    """,
    (
        k["id"],
        k["name"],
        k.get("english_name"),
        k.get("sarga_count")
    ))

    conn.commit()



def insert_sarga(conn, kanda_id, s):

    conn.execute("""
    INSERT OR REPLACE INTO sargas
    VALUES (?,?,?,?)
    """,
    (
        s["id"],
        kanda_id,
        s["name"],
        s.get("chapter")
    ))

    conn.commit()



def insert_shloka(conn, sarga_id, sh):

    conn.execute("""
    INSERT OR REPLACE INTO shlokas
    VALUES (?,?,?,?,?,?)
    """,
    (
        sh["id"],
        sarga_id,
        sh.get("sanskrit",""),
        sh.get("pratipada",""),
        sh.get("tat",""),
        sh.get("comment","")
    ))

    conn.commit()



def build():

    print("Creating database...")
    conn = create_db()


    print("Fetching Kandas...")

    kandas = api_get(
        BASE_URL + "/kandas"
    )


    if not kandas:
        print("Kanda loading failed")
        return



    total_shlokas = 0


    for kanda in kandas:

        kid = kanda["id"]

        print(
            "\nKanda:",
            kid,
            kanda["name"]
        )


        data = api_get(
            f"{BASE_URL}/kanda/{kid}?with_sarga=1"
        )


        if not data:
            continue


        insert_kanda(conn,data)


        sargas = data.get("sargas",[])


        for index,sarga in enumerate(sargas,1):

            sid = sarga["id"]

            print(
                f"  Sarga {index}/{len(sargas)} : {sid}"
            )


            insert_sarga(
                conn,
                kid,
                sarga
            )


            shloka = api_get(
                f"{BASE_URL}/shloka/{sid}"
            )


            if shloka:

                insert_shloka(
                    conn,
                    sid,
                    shloka
                )

                total_shlokas += 1


            time.sleep(0.15)



    conn.close()


    print("\n====================")
    print("BUILD COMPLETE")
    print("====================")
    print("Database:", DB_NAME)
    print("Shlokas saved:", total_shlokas)



if __name__ == "__main__":
    build()
