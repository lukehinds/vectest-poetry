import sqlite3
import sqlite_vec

db = sqlite3.connect(":memory:")
db.enable_load_extension(True)
sqlite_vec.load(db)
db.enable_load_extension(False)

vec_version, = db.execute("select vec_version()").fetchone()
print(f"vec_version={vec_version}")