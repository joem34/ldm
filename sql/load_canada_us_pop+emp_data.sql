--onatario population
DROP TABLE IF EXISTS ontario_synthetic_population_long;

CREATE TABLE ontario_synthetic_population_long (
	rowid integer primary key, 
	hhid integer,
	taz integer,
	hhinc integer,
	dtype integer,
	zone_id integer,
	num_pp integer);

COPY ontario_synthetic_population_long from 'C:/mto_longDistanceTravel/syntheticPopulation/households_qt.csv' csv header;

--ontario employment

DROP TABLE IF EXISTS ontario_employment;

CREATE TABLE ontario_employment (rowid integer, Naics2 integer,	emp_id	integer, zone_id integer);

COPY ontario_employment from 'C:/mto_longDistanceTravel/SocioeconomicData/Jobs_QT_Ontario.csv' csv header

--combine and aggregate ontario population and employment
DROP TABLE IF EXISTS ontario_zonal_pop_emp;
CREATE TABLE ontario_zonal_pop_emp AS

select COALESCE(p.zone_id, e.zone_id) as zone_id, COALESCE(population, 0) as population, COALESCE(employment, 0) as employment
from (
	SELECT zone_id, sum(num_pp) as population
	FROM ontario_synthetic_population_long
	GROUP BY zone_id
) as p full join
(
	SELECT zone_id, count(1) as employment
	FROM ontario_employment
	GROUP BY zone_id
) as e
on e.zone_id = p.zone_id
order by zone_id;

--canada population and employment
DROP TABLE IF EXISTS pop_jobs_data_canada;

CREATE TABLE pop_jobs_data_canada(
id integer,
cma_pr_code integer PRIMARY KEY,
population integer,
naics_99 integer,
naics_11 integer,
naics_21 integer,
naics_22 integer,
naics_23 integer,
naics_31 integer,
naics_41 integer,
naics_44 integer,
naics_48 integer,
naics_51 integer,
naics_52 integer,
naics_53 integer,
naics_54 integer,
naics_55 integer,
naics_56 integer,
naics_61 integer,
naics_62 integer,
naics_71 integer,
naics_72 integer,
naics_81 integer,
naics_91 integer,
zone_id integer);

COPY pop_jobs_data_canada FROM 'C:/mto_longDistanceTravel/SocioeconomicData/JobsPop_Canada_coded.csv' csv header;

alter table pop_jobs_data_canada ADD COLUMN total_employment integer;
update pop_jobs_data_canada set total_employment = (naics_99 + naics_11 + naics_21 + naics_22 + naics_23 + 
	naics_31 + naics_41 + naics_44 + naics_48 + naics_51 + naics_52 + naics_53 + naics_54 + 
	naics_55 + naics_56 + naics_61 + naics_62 + naics_71 + naics_72 + naics_81 + naics_91);

--us population and employment
DROP TABLE IF EXISTS pop_jobs_data_us;

CREATE TABLE pop_jobs_data_us(
f4z integer,
zone_id integer,
naics_11 integer,
naics_21 integer,
naics_22 integer,
naics_23 integer,
naics_31 integer,
naics_42 integer,
naics_44 integer,
naics_48 integer,
naics_51 integer,
naics_52 integer,
naics_53 integer,
naics_54 integer,
naics_55 integer,
naics_56 integer,
naics_61 integer,
naics_62 integer,
naics_71 integer,
naics_72 integer,
naics_81 integer,
naics_99 integer,
population integer);

COPY pop_jobs_data_us FROM 'C:/mto_longDistanceTravel/SocioeconomicData/JobsPop_US.csv' csv header;

alter table pop_jobs_data_us ADD COLUMN total_employment integer;
update pop_jobs_data_us set total_employment = (naics_99 + naics_11 + naics_21 + naics_22 + naics_23 + 
	naics_31 + naics_42 + naics_44 + naics_48 + naics_51 + naics_52 + naics_53 + naics_54 + 
	naics_55 + naics_56 + naics_61 + naics_62 + naics_71 + naics_72 + naics_81);

	--zones_pop_emp_type
	--internal_external_zone_aggregation



--create production and attraction for ontario + canada
drop table if exists canada_production_attraction CASCADE;
create table canada_production_attraction AS
	select a.zone_id, COALESCE (trips, 0) as production, population + employment as attraction, zone_type
	from (
		select zone_id, population, employment, 1 as zone_type
		from ontario_zonal_pop_emp

		union 

		select zone_id, population, total_employment, 2
		from pop_jobs_data_canada
	) as a
	full join domestic_trips_by_zone as b USING (zone_id)
		
	order by zone_id;

--map zone to lvl2 zones for gravity model validation

DROP VIEW IF EXISTS zone_to_lvl2_mapping;

create view zone_to_lvl2_mapping as
select id as zone_id, cd from ontario_zones
union 
select zone_id, zone_id from canada_production_attraction where zone_Type > 1
order by zone_id;

ALTER TABLE canada_production_attraction ADD COLUMN zone_lvl2 integer;
UPDATE canada_production_attraction as a SET zone_lvl2 = cd
FROM zone_to_lvl2_mapping as b
WHERE a.zone_id = b.zone_id;

CREATE INDEX canada_production_attraction_idx on canada_production_attraction (zone_id);
CLUSTER canada_production_attraction USING canada_production_attraction_idx;

select * 
from canada_production_attraction;
