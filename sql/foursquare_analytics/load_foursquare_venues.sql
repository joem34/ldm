DROP TABLE IF EXISTS foursquare.venues;
CREATE TABLE foursquare.venues ("venue_id" TEXT, "name" TEXT, "country" TEXT, "state" TEXT,
                        "lon" REAL, "lat" REAL, "category_name" TEXT, "category_id" TEXT, 
                        "search_cat_id" TEXT, "search_cat_name" TEXT,
                        "tips" INTEGER, "users" INTEGER, "checkins" INTEGER);

COPY foursquare.venues FROM 'C:/Users/Joe/canada/data/foursquare/by_category/all_venues.csv' csv header;

SELECT AddGeometryColumn('foursquare','venues', 'geom', 4269, 'POINT',2);

UPDATE foursquare.venues SET geom = ST_Transform(ST_SetSRID(ST_MakePoint(lon, lat), 4326), 4269);

CREATE INDEX fs_venues_gix ON foursquare.venues USING GIST (geom);
VACUUM foursquare.venues;

drop table if exists foursquare.zone_category_counts;

select id, pruid, v.search_cat_name, count(1), sum(checkins), z.geom
into foursquare.zone_category_counts
from level2_zones as  z, fs_venues as v
where ST_Within(v.geom, z.geom)
group by id, pruid, v.search_cat_name
order by id, v.search_cat_name;

SELECT Populate_Geometry_Columns();

select * from foursquare.zone_category_counts;
