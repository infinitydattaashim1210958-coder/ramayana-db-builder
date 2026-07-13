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
-- ==========================================
-- TRANSLATORS
-- ==========================================

CREATE TABLE translators (

    id INTEGER PRIMARY KEY,

    name TEXT NOT NULL,

    language TEXT,

    website TEXT,

    license TEXT,

    display_order INTEGER DEFAULT 0

);

-- ==========================================
-- TRANSLATIONS
-- ==========================================

CREATE TABLE translations (

    id INTEGER PRIMARY KEY,

    shloka_id INTEGER NOT NULL,

    translator_id INTEGER NOT NULL,

    translation TEXT NOT NULL,

    FOREIGN KEY(shloka_id)
        REFERENCES shlokas(id)
        ON DELETE CASCADE,

    FOREIGN KEY(translator_id)
        REFERENCES translators(id)
        ON DELETE CASCADE

);

-- ==========================================
-- COMMENTATORS
-- ==========================================

CREATE TABLE commentators (

    id INTEGER PRIMARY KEY,

    name TEXT NOT NULL,

    language TEXT,

    website TEXT,

    license TEXT,

    display_order INTEGER DEFAULT 0

);

-- ==========================================
-- COMMENTARIES
-- ==========================================

CREATE TABLE commentaries (

    id INTEGER PRIMARY KEY,

    shloka_id INTEGER NOT NULL,

    commentator_id INTEGER NOT NULL,

    commentary TEXT NOT NULL,

    FOREIGN KEY(shloka_id)
        REFERENCES shlokas(id)
        ON DELETE CASCADE,

    FOREIGN KEY(commentator_id)
        REFERENCES commentators(id)
        ON DELETE CASCADE

);

-- ==========================================
-- WORD MEANINGS
-- ==========================================

CREATE TABLE word_meanings (

    id INTEGER PRIMARY KEY,

    shloka_id INTEGER NOT NULL,

    language TEXT,

    meaning TEXT,

    FOREIGN KEY(shloka_id)
        REFERENCES shlokas(id)
        ON DELETE CASCADE

);

-- ==========================================
-- CROSS REFERENCES
-- ==========================================

CREATE TABLE cross_references (

    id INTEGER PRIMARY KEY,

    shloka_id INTEGER NOT NULL,

    reference TEXT,

    description TEXT,

    FOREIGN KEY(shloka_id)
        REFERENCES shlokas(id)
        ON DELETE CASCADE

);

-- ==========================================
-- BOOKMARKS
-- ==========================================

CREATE TABLE bookmarks (

    id INTEGER PRIMARY KEY,

    shloka_id INTEGER NOT NULL,

    created_at TEXT DEFAULT CURRENT_TIMESTAMP,

    note TEXT,

    FOREIGN KEY(shloka_id)
        REFERENCES shlokas(id)
        ON DELETE CASCADE

);

-- ==========================================
-- READING HISTORY
-- ==========================================

CREATE TABLE reading_history (

    id INTEGER PRIMARY KEY,

    shloka_id INTEGER NOT NULL,

    last_read_at TEXT DEFAULT CURRENT_TIMESTAMP,

    reading_position INTEGER DEFAULT 0,

    FOREIGN KEY(shloka_id)
        REFERENCES shlokas(id)
        ON DELETE CASCADE

);

-- ==========================================
-- DOWNLOADS
-- ==========================================

CREATE TABLE downloads (

    id INTEGER PRIMARY KEY,

    package_name TEXT UNIQUE,

    version TEXT,

    downloaded_at TEXT DEFAULT CURRENT_TIMESTAMP,

    size_bytes INTEGER,

    status TEXT

);

-- ==========================================
-- USER SETTINGS
-- ==========================================

CREATE TABLE user_settings (

    key TEXT PRIMARY KEY,

    value TEXT

);

INSERT INTO user_settings(key,value) VALUES

('theme','system'),

('language','bn'),

('font_size','18'),

('keep_screen_on','false'),

('show_translation','true'),

('show_transliteration','true'),

('show_commentary','true');

-- ==========================================
-- INDEXES
-- ==========================================

CREATE INDEX idx_sarga_kanda
ON sargas(kanda_id);

CREATE INDEX idx_shloka_sarga
ON shlokas(sarga_id);

CREATE INDEX idx_translation_shloka
ON translations(shloka_id);

CREATE INDEX idx_commentary_shloka
ON commentaries(shloka_id);

CREATE INDEX idx_wordmeaning_shloka
ON word_meanings(shloka_id);

CREATE INDEX idx_bookmark_shloka
ON bookmarks(shloka_id);

CREATE INDEX idx_history_shloka
ON reading_history(shloka_id);

CREATE INDEX idx_reference
ON shlokas(reference);
-- ==========================================
-- FULL TEXT SEARCH (FTS5)
-- ==========================================

CREATE VIRTUAL TABLE search_index
USING fts5(

    reference,

    sanskrit,

    transliteration,

    translation,

    commentary,

    content=''

);

-- ==========================================
-- INSERT TRIGGER
-- ==========================================

CREATE TRIGGER shlokas_ai
AFTER INSERT ON shlokas
BEGIN

INSERT INTO search_index(
rowid,
reference,
sanskrit,
transliteration
)

VALUES(

new.id,
new.reference,
new.sanskrit,
new.transliteration

);

END;

-- ==========================================
-- UPDATE TRIGGER
-- ==========================================

CREATE TRIGGER shlokas_au

AFTER UPDATE ON shlokas

BEGIN

UPDATE search_index

SET

reference=new.reference,

sanskrit=new.sanskrit,

transliteration=new.transliteration

WHERE rowid=new.id;

END;

-- ==========================================
-- DELETE TRIGGER
-- ==========================================

CREATE TRIGGER shlokas_ad

AFTER DELETE ON shlokas

BEGIN

DELETE FROM search_index

WHERE rowid=old.id;

END;

-- ==========================================
-- DATABASE OPTIMIZATION
-- ==========================================

PRAGMA cache_size=-50000;

PRAGMA temp_store=MEMORY;

PRAGMA mmap_size=268435456;

PRAGMA page_size=4096;

PRAGMA auto_vacuum=INCREMENTAL;

PRAGMA secure_delete=OFF;

PRAGMA optimize;

ANALYZE;
-- ==========================================
-- DATABASE VERSION
-- ==========================================

CREATE TABLE database_version (

    version INTEGER PRIMARY KEY,

    schema_name TEXT,

    created_at TEXT DEFAULT CURRENT_TIMESTAMP

);

INSERT INTO database_version
(version,schema_name)

VALUES

(1,'Ramayana Production Schema');

-- ==========================================
-- READING PROGRESS
-- ==========================================

CREATE TABLE reading_progress (

    id INTEGER PRIMARY KEY,

    shloka_id INTEGER NOT NULL,

    progress REAL DEFAULT 0,

    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(shloka_id)
        REFERENCES shlokas(id)
        ON DELETE CASCADE

);

-- ==========================================
-- FAVOURITES
-- ==========================================

CREATE TABLE favourites (

    id INTEGER PRIMARY KEY,

    shloka_id INTEGER NOT NULL,

    created_at TEXT DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(shloka_id)
        REFERENCES shlokas(id)
        ON DELETE CASCADE

);

-- ==========================================
-- RECENT SEARCHES
-- ==========================================

CREATE TABLE recent_searches (

    id INTEGER PRIMARY KEY,

    keyword TEXT NOT NULL,

    searched_at TEXT DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================
-- APP STATISTICS
-- ==========================================

CREATE TABLE statistics (

    key TEXT PRIMARY KEY,

    value INTEGER DEFAULT 0

);

INSERT INTO statistics(key,value)
VALUES

('total_app_opens',0),

('total_shlokas_read',0),

('total_bookmarks',0),

('total_searches',0);

-- ==========================================
-- LAST SYNC
-- ==========================================

CREATE TABLE sync_info (

    id INTEGER PRIMARY KEY,

    source TEXT,

    last_sync TEXT,

    status TEXT

);

-- ==========================================
-- DOWNLOAD PACKS
-- ==========================================

CREATE TABLE downloaded_packs (

    id INTEGER PRIMARY KEY,

    package_name TEXT UNIQUE,

    package_version TEXT,

    package_size INTEGER,

    installed_at TEXT DEFAULT CURRENT_TIMESTAMP

);

-- ==========================================
-- VIEWS
-- ==========================================

CREATE VIEW v_kandas AS

SELECT

k.id,

k.code,

k.name,

k.english_name,

k.total_sargas,

k.total_shlokas,

COUNT(DISTINCT s.id) AS sarga_count

FROM kandas k

LEFT JOIN sargas s

ON s.kanda_id=k.id

GROUP BY k.id;

-- ==========================================

CREATE VIEW v_sargas AS

SELECT

s.id,

s.kanda_id,

k.name AS kanda_name,

s.serial,

s.title,

s.total_shlokas

FROM sargas s

JOIN kandas k

ON k.id=s.kanda_id;

-- ==========================================

CREATE VIEW v_shlokas AS

SELECT

sh.id,

sh.reference,

k.name AS kanda,

sg.serial AS sarga,

sh.serial AS shloka,

sh.sanskrit,

sh.transliteration

FROM shlokas sh

JOIN sargas sg

ON sg.id=sh.sarga_id

JOIN kandas k

ON k.id=sg.kanda_id;

-- ==========================================
-- HEALTH CHECK
-- ==========================================

CREATE VIEW database_health AS

SELECT

(SELECT COUNT(*) FROM kandas) AS kandas,

(SELECT COUNT(*) FROM sargas) AS sargas,

(SELECT COUNT(*) FROM shlokas) AS shlokas,

(SELECT COUNT(*) FROM translations) AS translations,

(SELECT COUNT(*) FROM commentaries) AS commentaries;

-- ==========================================
-- APP INFO
-- ==========================================

INSERT INTO metadata(key,value)

VALUES

('schema_status','production'),

('fts_enabled','true'),

('foreign_keys','enabled'),

('created_by','Ashim Datta'),

('database_engine','SQLite'),

('project','Ramayana Offline');

-- ==========================================
-- FINAL OPTIMIZATION
-- ==========================================

PRAGMA foreign_keys=ON;

PRAGMA journal_mode=WAL;

PRAGMA synchronous=NORMAL;

PRAGMA temp_store=MEMORY;

PRAGMA optimize;

VACUUM;

ANALYZE;
