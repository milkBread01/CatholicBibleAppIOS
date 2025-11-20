import sqlite3
import os

# ===============================
# CONFIGURATION
# ===============================

# Change this path to where you want your db created
DB_PATH = r"/Users/normaguzman/Documents/SwiftCode/gitHubRepos/CatholicBibleAppIOS/Python/user_info.db"


# ===============================
# SQL SCHEMA
# ===============================

SCHEMA_SQL = """
-- =========================================
-- User Preferences
-- theme: 'light', 'dark', 'sepia'
-- text_size: 'small', 'medium', 'large'
-- share_location: 0 (false), 1 (true)
-- =========================================
CREATE TABLE IF NOT EXISTS user_preferences (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    theme TEXT NOT NULL CHECK (
        theme IN ('light', 'dark', 'sepia')
    ) DEFAULT 'light',
    text_size TEXT NOT NULL CHECK (
        text_size IN ('small', 'medium', 'large')
    ) DEFAULT 'medium',
    share_location INTEGER NOT NULL CHECK (
        share_location IN (0, 1)
    ) DEFAULT 0,
    date_added    TEXT NOT NULL DEFAULT (datetime('now')),
    date_modified TEXT NOT NULL DEFAULT (datetime('now'))
);

-- =========================================
-- Bible Highlights
-- Stores highlights per verse for the user
-- =========================================
CREATE TABLE IF NOT EXISTS bible_highlights (
    id INTEGER PRIMARY KEY,
    series_name TEXT NOT NULL, 
    book_id INTEGER NOT NULL,
    chapter INTEGER NOT NULL,
    verse_start INTEGER NOT NULL,
    verse_end   INTEGER NOT NULL,
    highlight_color TEXT NOT NULL CHECK (
        highlight_color IN ('yellow', 'green', 'blue', 'red', 'purple', 'orange')
    ),
    additional_notes TEXT,
    date_added    TEXT NOT NULL DEFAULT (datetime('now')),
    date_modified TEXT NOT NULL DEFAULT (datetime('now')),
    CHECK (verse_start <= verse_end)
);


-- =========================================
-- Reading Progress (stub, expandable later)
-- Tracks where the user left off
-- =========================================
CREATE TABLE IF NOT EXISTS bible_bookmarks (
    id INTEGER PRIMARY KEY,
    series_name TEXT NOT NULL,
    book_id INTEGER NOT NULL,
    chapter INTEGER NOT NULL,
    verse_start INTEGER,
    verse_end   INTEGER,
    note TEXT,
    date_added    TEXT NOT NULL DEFAULT (datetime('now')),
    date_modified TEXT NOT NULL DEFAULT (datetime('now')),
    CHECK (
        (verse_start IS NULL AND verse_end IS NULL)
        OR
        (verse_start IS NOT NULL AND verse_end IS NOT NULL AND verse_start <= verse_end)
    )
);
"""


# ===============================
# SCRIPT EXECUTION
# ===============================

def ensure_path_exists(path: str) -> None:
    """Ensure parent directory exists."""
    directory = os.path.dirname(path)
    if not os.path.exists(directory):
        print(f"Creating directory: {directory}")
        os.makedirs(directory, exist_ok=True)


def create_database(db_path: str) -> None:
    """Create the SQLite database and tables."""
    ensure_path_exists(db_path)

    print(f"📘 Creating database at: {db_path}")

    # Connect to SQLite (creates file if not exists)
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Execute schema
    cursor.executescript(SCHEMA_SQL)

    conn.commit()
    conn.close()

    print("✅ Database created successfully.")
    print("📚 Tables included: user_preferences, bible_highlights, reading_progress")


if __name__ == "__main__":
    create_database(DB_PATH)
