--create a new table of external zones that also has the zone id, geometry, and metro_region indicator
--maybe in future we will need other columns from the external zones shapefile but I double it.

--NOTE: currently don't include hawaii + honolulu (no zone id allocated)
DROP TABLE IF EXISTS external_zone_codes;
CREATE TABLE external_zone_codes(label text, key text, zone_id integer, description text);

COPY external_zone_codes FROM 'C:/mto_longDistanceTravel/external_zone_codes.csv' csv header;

DROP TABLE IF EXISTS external_zones_v2;

CREATE TABLE external_zones_v2 AS 
select 
	c.zone_id, c.label, c.key, 
	COALESCE(c.description, f3_name) as description, 
	CASE WHEN f3_name is not null then metro_regi
	     WHEN cmapuid is not null then 1
	     WHEN description like '%remaining%' then 0
	     ELSE 2 END as metro_region,
	geom
from external_zone_codes as c, external_zones as e
where COALESCE(cmapuid, pruid, f3_name) = c.key
order by zone_id;

DROP TABLE IF EXISTS external_zone_codes;
DROP TABLE IF EXISTS external_zones;

select Populate_Geometry_Columns();