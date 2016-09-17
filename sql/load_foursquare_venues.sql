DROP TABLE IF EXISTS fs_venues;
CREATE TABLE fs_venues ("venue_id" TEXT PRIMARY KEY, "name" TEXT, "country" TEXT, "state" TEXT,
                        "lon" REAL, "lat" REAL, "category_name" TEXT, "category_id" TEXT, 
                        "tips" INTEGER, "users" INTEGER, "checkins" INTEGER);

COPY fs_venues FROM '/Users/joemolloy/Projects/canadia/output/all_venues.csv' csv header;

SELECT AddGeometryColumn('fs_venues', 'geom', 4269, 'POINT',2);

UPDATE fs_venues SET geom = ST_Transform(ST_SetSRID(ST_MakePoint(lon, lat), 4326), 4269);

CREATE INDEX fs_venues_gix ON fs_venues USING GIST (geom);

select * from fs_venues