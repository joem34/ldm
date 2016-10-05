
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

SELECT zone_lvl2 as alt, pa.*, z2.metro as alt_is_metro , CAST(z2.pruid = 24 AS INTEGER) speak_french
INTO destination_attributes
from (
	SELECT zone_lvl2, 
	sum(population) as population, sum(total_employment) as employment,
			sum(naics_11) as naics_11,sum(naics_21) as naics_21,sum(naics_22) as naics_22,
			sum(naics_23) as naics_23,sum(naics_31) as naics_31,sum(naics_41) as naics_41,
			sum(naics_44) as naics_44,sum(naics_48) as naics_48,sum(naics_51) as naics_51,
			sum(naics_52) as naics_52,sum(naics_53) as naics_53,
			sum(naics_54) as naics_54, sum(naics_55) as naics_55,sum(naics_56) as naics_56,
			sum(naics_61) as naics_61,sum(naics_62) as naics_62,sum(naics_71) as naics_71,
			sum(naics_72) as naics_72,sum(naics_81) as naics_81,sum(naics_91) as naics_91
			FROM public.canada_production_attraction
			group by zone_lvl2
			order by zone_lvl2
	) as pa
JOIN level2_zones as z2 on pa.zone_lvl2 = z2.id;

select * from destination_attributes; --should be 117 canadian zones

