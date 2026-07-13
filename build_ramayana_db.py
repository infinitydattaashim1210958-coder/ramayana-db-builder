import requests
import sqlite3
import time


BASE_URL = "https://ramayana.hindbiswas.com/api"
DB_NAME = "ramayana.db"


def api_get(url, retries=5):

   headers = {
    "User-Agent": "Mozilla/5.0",
    "Accept": "*/*",
    "Content-Type": "application/json"
}
    for attempt in range(retries):

        try:
            response = requests.get(
                url,
                headers=headers,
                timeout=60
            )

            print(
                "Request:",
                url,
                "Status:",
                response.status_code
            )

            if response.status_code == 200:
                return response.json()

        except Exception as e:
            print(
                "Attempt failed:",
                attempt + 1,
                e
            )

        time.sleep(5)

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
        chapter INTEGER,
        FOREIGN KEY(kanda_id)
        REFERENCES kandas(id)
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
        FOREIGN KEY(sarga_id)
        REFERENCES sargas(id)
    )
    """)


    conn.commit()

    return conn



def insert_kanda(conn, data):

    conn.execute("""
    INSERT OR REPLACE INTO kandas
    VALUES (?,?,?,?)
    """,
    (
        data["id"],
        data["name"],
        data.get("english_name"),
        data.get("sarga_count")
    ))

    conn.commit()



def insert_sarga(conn, kanda_id, data):

    conn.execute("""
    INSERT OR REPLACE INTO sargas
    VALUES (?,?,?,?)
    """,
    (
        data["id"],
        kanda_id,
        data.get("name"),
        data.get("chapter")
    ))

    conn.commit()



def insert_shloka(conn, sarga_id, data):

    conn.execute("""
    INSERT OR REPLACE INTO shlokas
    VALUES (?,?,?,?,?,?)
    """,
    (
        data["id"],
        sarga_id,
        data.get("sanskrit", ""),
        data.get("pratipada", ""),
        data.get("tat", ""),
        data.get("comment", "")
    ))

    conn.commit()


def build():

    print("Creating database...")

    conn = create_db()


    print("Using Kanda list...")

    kandas = [
        {"id": 1},
        {"id": 2},
        {"id": 3},
        {"id": 4},
        {"id": 5},
        {"id": 6}
    ]


    total_sargas = 0
    total_shlokas = 0


    for kanda in kandas:

        kanda_id = kanda["id"]

        print(
            "\nKanda:",
            kanda_id
    )



        kanda_data = api_get(
            f"{BASE_URL}/kanda/{kanda_id}?with_sarga=1"
        )


        if not kanda_data:

            continue



        insert_kanda(
            conn,
            kanda_data
        )


        sargas = kanda_data.get(
            "sargas",
            []
        )


        for index, sarga in enumerate(
            sargas,
            start=1
        ):


            sarga_id = sarga["id"]


            print(
                f"Sarga {index}/{len(sargas)} ID:{sarga_id}"
            )


            insert_sarga(
                conn,
                kanda_id,
                sarga
            )


            total_sargas += 1



            # Get all shlokas of this sarga

            sarga_data = api_get(
                f"{BASE_URL}/sarga/{sarga_id}?with_shloka=1"
            )


            if sarga_data:


                shlokas = sarga_data.get(
                    "shlokas",
                    []
                )


                for shloka in shlokas:


                    insert_shloka(
                        conn,
                        sarga_id,
                        shloka
                    )


                    total_shlokas += 1



            time.sleep(0.2)



    conn.close()


    print("\n==========================")
    print("RAMAYANA DATABASE COMPLETE")
    print("==========================")

    print(
        "Database:",
        DB_NAME
    )

    print(
        "Total Sargas:",
        total_sargas
    )

    print(
        "Total Shlokas:",
        total_shlokas
    )



if __name__ == "__main__":

    build()
