PRAGMA foreign_keys = ON;

-- ===========================
-- METADATA
-- ===========================

CREATE TABLE metadata(
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

INSERT INTO metadata VALUES
('app','Ramayana'),
('version','1.0.0');

-- ===========================
-- KANDAS
-- ===========================

CREATE TABLE kandas(

    id INTEGER PRIMARY KEY,

    code TEXT UNIQUE NOT NULL,

    name TEXT NOT NULL,

    english_name TEXT,

    description TEXT,

    total_sargas INTEGER DEFAULT 0,

    total_shlokas INTEGER DEFAULT 0,

    sort_order INTEGER

);

-- ===========================
-- SARGAS
-- ===========================

CREATE TABLE sargas(

    id INTEGER PRIMARY KEY,

    kanda_id INTEGER NOT NULL,

    serial INTEGER,

    title TEXT,

    english_title TEXT,

    total_shlokas INTEGER DEFAULT 0,

    FOREIGN KEY(kanda_id)
    REFERENCES kandas(id)
    ON DELETE CASCADE

);

-- ===========================
-- SHLOKAS
-- ===========================

CREATE TABLE shlokas(

    id INTEGER PRIMARY KEY,

    sarga_id INTEGER NOT NULL,

    serial INTEGER,

    reference TEXT UNIQUE,

    sanskrit TEXT,

    transliteration TEXT,

    meter TEXT,

    speaker TEXT,

    listener TEXT,

    FOREIGN KEY(sarga_id)
    REFERENCES sargas(id)
    ON DELETE CASCADE

);
