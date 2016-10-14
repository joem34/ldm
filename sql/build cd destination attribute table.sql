
--create production and attraction for ontario + canada
drop table if exists canada_production_attraction CASCADE;
create table canada_production_attraction AS
	select 	zone_id, COALESCE (trips, 0) as production, 
		population, total_employment, 
		naics_11,naics_21,naics_22,naics_23,naics_31,naics_41,naics_44,naics_48,naics_51,naics_52,naics_53,naics_54,
		naics_55,naics_56,naics_61,naics_62,naics_71,naics_72,naics_81,naics_91,
		population + total_employment as attraction, zone_type
	from (
		select 	zone_id, population, total_employment, 
			naics_11,naics_21,naics_22,naics_23,naics_31,naics_41,naics_44,naics_48,naics_51,naics_52,naics_53,naics_54,
			naics_55,naics_56,naics_61,naics_62,naics_71,naics_72,naics_81,naics_91,
			1 as zone_type
		from pop_jobs_data_ontario

		union 

		select zone_id, population, total_employment,
			naics_11,naics_21,naics_22,naics_23,naics_31,naics_41,naics_44,naics_48,naics_51,naics_52,naics_53,naics_54,
			naics_55,naics_56,naics_61,naics_62,naics_71,naics_72,naics_81,naics_91,
			2 as zone_type
		from pop_jobs_data_canada
	) as a
	full join domestic_trips_by_zone as b USING (zone_id)
		
	order by zone_id;

--map zone to lvl2 zones for gravity model validation
DROP VIEW IF EXISTS zone_to_lvl2_mapping;

create view zone_to_lvl2_mapping as
	select id as zone_id, cd from ontario_zones
union 
	select zone_id, z2.id 
	from canada_production_attraction as cpa
	inner join level2_zones as z2 on zone_id = z2.ext_zone_id
	where cpa.zone_type > 1

order by zone_id;

--add lvl2 zones to canada zone_attributes
ALTER TABLE canada_production_attraction ADD COLUMN zone_lvl2 integer;
UPDATE canada_production_attraction as a SET zone_lvl2 = cd
FROM zone_to_lvl2_mapping as b
WHERE a.zone_id = b.zone_id;

CREATE INDEX canada_production_attraction_idx on canada_production_attraction (zone_id);
CLUSTER canada_production_attraction USING canada_production_attraction_idx;

select * 
from canada_production_attraction;


--build attribute table from canada_production_attraction
DROP TABLE IF EXISTS destination_attributes;

SELECT zone_lvl2 as alt, pa.*, z2.metro as alt_is_metro , CAST(z2.pruid = 24 AS INTEGER) speak_french, 
	fs.arts_entertainment as fs_arts_entertainment, 
	COALESCE (fs.hotel, 0) as fs_hotel, 
	COALESCE (fs.medical, 0) as fs_medical, 
	COALESCE (fs.outdoor, 0) as fs_outdoor, 
	COALESCE (fs.services, 0) as fs_services, 
	COALESCE (fs.ski_area, 0) as fs_skiarea
INTO destination_attributes
from (
	SELECT zone_lvl2, 
	sum(population) as population, sum(total_employment) as employment,
			sum(naics_11 + naics_21 + naics_22 + naics_23 + naics_31) as goods_industry,
			sum(naics_41 + naics_44 + naics_48 + naics_51 + naics_52 + naics_53 + naics_54 + naics_55 + naics_56) as service_industry,
			sum(naics_51 + naics_52 + naics_53 + naics_54 + naics_55) as professional_industry,
			sum(naics_61 + naics_62) as employment_health,
			sum(naics_71) as arts_entertainment,
			sum(naics_71 + naics_72) as leisure_hospitality
			
			FROM public.canada_production_attraction
			group by zone_lvl2
			order by zone_lvl2
	) as pa
JOIN level2_zones as z2 on z2.id = pa.zone_lvl2
left outer JOIN foursquare.zone_checkins_wide as fs on fs.zone_id = pa.zone_lvl2;

select * from destination_attributes; --should be 117 canadian zones

