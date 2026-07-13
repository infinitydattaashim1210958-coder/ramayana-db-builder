PRAGMA foreign_keys = ON;

-- ==========================================
-- KANDAS
-- ==========================================

INSERT INTO kandas
(id,code,name,english_name,sort_order)

VALUES

(1,'bala','बालकाण्ड','Bala Kanda',1),

(2,'ayodhya','अयोध्याकाण्ड','Ayodhya Kanda',2),

(3,'aranya','अरण्यकाण्ड','Aranya Kanda',3),

(4,'kishkindha','किष्किन्धाकाण्ड','Kishkindha Kanda',4),

(5,'sundara','सुन्दरकाण्ड','Sundara Kanda',5),

(6,'yuddha','युद्धकाण्ड','Yuddha Kanda',6),

(7,'uttara','उत्तरकाण्ड','Uttara Kanda',7);

-- ==========================================
-- LANGUAGES
-- ==========================================

INSERT OR IGNORE INTO languages
(id,code,name,native_name)

VALUES

(1,'sa','Sanskrit','संस्कृत'),

(2,'bn','Bangla','বাংলা'),

(3,'en','English','English'),

(4,'hi','Hindi','हिन्दी');

-- ==========================================
-- DEFAULT SETTINGS
-- ==========================================

INSERT OR IGNORE INTO user_settings
(key,value)

VALUES

('theme','system'),

('language','bn'),

('font_size','18'),

('keep_screen_on','false'),

('show_translation','true'),

('show_commentary','true'),

('show_transliteration','true');

-- ==========================================
-- DEFAULT STATISTICS
-- ==========================================

INSERT OR IGNORE INTO statistics
(key,value)

VALUES

('total_app_opens',0),

('total_searches',0),

('total_bookmarks',0),

('total_shlokas_read',0);


