SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd "$SCRIPT_DIR"

# ========== ビルド ==========
# ソースコード取得
wget https://www.sqlite.org/2019/sqlite-src-3290000.zip
unzip /sqlite-src-3290000.zip

# 合併(amalgamation)ソースコード取得
wget https://www.sqlite.org/2019/sqlite-autoconf-3290000.tar.gz
tar xf sqlite-autoconf-3290000.tar.gz

# 合併にあるいくつかのファイルをソース側へコピーする
cp ./sqlite-autoconf-3290000/sqlite3.c ./sqlite-src-3290000/sqlite3.c
cp ./sqlite-autoconf-3290000/sqlite3.h ./sqlite-src-3290000/sqlite3.h
cp ./sqlite-autoconf-3290000/shell.c ./sqlite-src-3290000/shell.c

# ソースのディレクトリへ移動
cd sqlite-src-3290000

# オプション付与
./configure \
--enable-fts4 \
--enable-fts5 \
--enable-json1 \
--enable-update-limit \
--enable-geopoly \
--enable-rtree \
--enable-session \
LIBS="-lz" \
LDFLAGS="`icu-config --ldflags`" \
CFLAGS="`icu-config --cppflags` -DHAVE_READLINE=1 -DSQLITE_ALLOW_URI_AUTHORITY=1 -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_DBPAGE_VTAB=1 -DSQLITE_ENABLE_DBSTAT_VTAB=1 -DSQLITE_ENABLE_DESERIALIZE=1 -DSQLITE_ENABLE_FTS4=1 -DSQLITE_ENABLE_FTS5=1 -DSQLITE_ENABLE_GEOPOLY=1 -DSQLITE_ENABLE_ICU=1 -DSQLITE_ENABLE_JSON1=1 -DSQLITE_ENABLE_MEMSYS3=1 -DSQLITE_ENABLE_PREUPDATE_HOOK=1 -DSQLITE_ENABLE_RTREE=1 -DSQLITE_ENABLE_SESSION=1 -DSQLITE_ENABLE_SNAPSHOT=1 -DSQLITE_ENABLE_STMTVTAB=1 -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1 -DSQLITE_ENABLE_UNLOCK_NOTIFY=1 -DSQLITE_INTROSPECTION_PRAGMAS=1 -DSQLITE_USE_ALLOCA=1 -DSQLITE_USE_FCNTL_TRACE=1 -DSQLITE_HAVE_ZLIB=1"

# ビルド
time make

# ========== 確認 ==========
# オプション確認
./sqlite3 :memory: "pragma compile_options;"

# delete文内でlimit句を使っても「」エラーが出ないことを確認
./sqlite3 :memory: \
"create table T(A integer);" \
"delete from T limit 1;"

# limitで指定した上限までしか削除されないことを確認
./sqlite3 :memory: \
"create table T(A integer);" \
"insert into T values(0);" \
"insert into T values(1);" \
"delete from T limit 1;" \
"select count(*) from T;"

