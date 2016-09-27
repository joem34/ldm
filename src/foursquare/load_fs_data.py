from pysqlite2 import dbapi2 as sqlite3
import csv

print sqlite3.__file__
print sqlite3.sqlite_version



def record_generator():
    with open('dataset_TIST2015/dataset_TIST2015_POIs.txt', 'r') as f:
        reader = csv.reader(f, delimiter='\t', quotechar='\'')
        for row in reader:
            yield tuple([row[0], row[3], row[4], str("POINT(%s %s)" % (row[2], row[1]))])



conn = sqlite3.connect("input/canada.sqlite")
conn.enable_load_extension(True)
conn.execute('SELECT * from external_zones limit 10;')
curs = conn.cursor()
print "test"

conn.execute('SELECT load_extension("mod_spatialite")')
cursor = conn.cursor()



insert_query = "INSERT INTO fs_venues (id, category, country, geom) " \
               "VALUES (?, ?, ?, GeomFromText(?, 4326))"

records = list(record_generator())
print records[0]
print "number of records", len(records)

#need to filter venues, only add venues within a geometry

with conn:
    print "inserting records"
    conn.execute("begin")
    for row in records[:100]:
        #print """VALUES (?, ?, ?, Transform(GeomFromText('%s', 4326), 4269)""" % row[3]
        #dont need to convert from 4236 (wgs84) to 4269 (NAD83)
        cursor.execute("""INSERT INTO fs_venues (id, category, country, geom) VALUES (?, ?, ?, GeomFromText(?, 4269))""", row)
    conn.execute("commit")
#for r in records:
#    print r

#print "inserting records"
#cursor.executemany(insert_query, records)