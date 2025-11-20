import json
import sqlite3
from pathlib import Path

JSON_FILE = r"/Users/normaguzman/Documents/SwiftCode/gitHubRepos/CatholicBibleAppIOS/PublicDomainTexts/New_Testament.json"

DB_FILE = r"/Users/normaguzman/Documents/SwiftCode/gitHubRepos/CatholicBibleAppIOS/Python/drv_new_testament.db"
"""
JSON FILE Structure:
{
    bookName: String,
    description: String,
    chapters: {
        chapterNumber: {
            description: String // chapter description
            verses: {
                verseNumber: { // ex 1.1 (chapter 1, verse 1)
                    text: String
                }
            },
            comments: {
                commentNumber: { // ex 1.6 (chapter 1, verse 6) <- comment refers to chapter 1 verse 6
                    text: String // comment text
                }
            }
        }
    }
},
"""
def main():

    # Load Json File
    with open(JSON_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)   # Expecting a list of dicts

    # 2) Connect to (or create) the SQLite database
    conn = sqlite3.connect(DB_FILE)
    cur = conn.cursor()

    # 3) Create db
    cur.executescript("""
        DROP TABLE IF EXISTS bible_books;
        DROP TABLE IF EXISTS bible_verses;
        DROP TABLE IF EXISTS bible_comments;
        CREATE TABLE bible_books(
            id INTEGER PRIMARY KEY,
            name TEXT,
            description TEXT,
            ord INTEGER
        );

        CREATE TABLE bible_verses(
            id INTEGER PRIMARY KEY,
            book_id INTEGER,
            chapter INTEGER,
            verse INTEGER,
            text TEXT,
            FOREIGN KEY(book_id) REFERENCES bible_books(id)
        );

        CREATE TABLE bible_comments(
            id INTEGER PRIMARY KEY,
            book_id INTEGER,
            chapter INTEGER,
            verse INTEGER,
            comment TEXT
        );

    """)

    for i, row in enumerate(data):
        book_name = row['bookName']
        book_description = row.get('description', '')
        book_ord = i + 1  # Using index as order

        # Insert book
        cur.execute("""
            INSERT INTO bible_books (name, description, ord)
            VALUES (?, ?, ?)
        """, (book_name, book_description, book_ord))
        book_id = cur.lastrowid

        chapters = row.get('chapters', {})
        for chapter_num_str, chapter_data in chapters.items():
            chapter_num = int(chapter_num_str)

            # Insert verses
            verses = chapter_data.get('verses', {})
            for verse_num_str, verse_data in verses.items():
                verse_num = int(verse_num_str.split(":")[1]) # verse number has syntax 1:3, so split by ":",
                
                if isinstance(verse_data, str):
                    verse_text = verse_data
                elif isinstance(verse_data, dict):
                    verse_text = verse_data.get("text", "")
                else:
                    verse_text = ""


                cur.execute("""
                    INSERT INTO bible_verses (book_id, chapter, verse, text)
                    VALUES (?, ?, ?, ?)
                """, (book_id, chapter_num, verse_num, verse_text))

            # Insert comments
            comments = chapter_data.get('comments', {})
            for comment_num_str, comment_data in comments.items():
                comment_num = int(comment_num_str.split(":")[1])

                if isinstance(comment_data,str):
                    comment_text = comment_data
                elif isinstance(comment_data, dict):
                    comment_text = comment_data.get("text","")
                elif isinstance(comment_data, list):
                    # join multiple comments into one block
                    comment_text = "\n\n".join(str(c) for c in comment_data)
                else:
                    comment_text = ""

                cur.execute("""
                    INSERT INTO bible_comments (book_id, chapter, verse, comment)
                    VALUES (?, ?, ?, ?)
                """, (book_id, chapter_num, comment_num, comment_text))
    # Commit changes and close the connection
    conn.commit()
    conn.close()    
    print("Database created and populated successfully.")


if __name__ == "__main__":
    main()

    # run in terminal by: python3 json2sqlite.py