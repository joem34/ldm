--get unique combinations of cma and census division, store temporarily
drop table if exists temp_cd_cma_intersection;
create table temp_cd_cma_intersection(id SERIAL PRIMARY KEY, pruid integer, cduid integer, cdname varchar, cmauid integer, cmaname varchar);
SELECT AddGeometryColumn('temp_cd_cma_intersection', 'geom', 4269, 'MULTIPOLYGON', 2);

INSERT INTO temp_cd_cma_intersection (pruid, cduid, cdname, cmauid, cmaname, geom)
select pruid, cduid, cdname, cmauid, cmaname,
	case when GeometryType (geom) = 'GEOMETRYCOLLECTION' then ST_CollectionExtract(geom, 3)
	else ST_Multi(geom) end
from (
	select CAST(cd.pruid as integer), CAST(cd.cduid as integer), cd.cdname, CAST(cmas.cmauid as INTEGER), cmas.cmaname,
		ST_Intersection( cd.geom, cmas.geom) as geom
	from census_divisions as cd, cmas
	where  cd.pruid = '35' and cmas.pruid = '35' and cmas.cmatype = 'B'
	and (not ST_Touches(cd.geom, cmas.geom) and ST_Intersects( cd.geom, cmas.geom)) 
	order by cduid
	) 
	as a;
--new zone codes: 0 - 100: internal zones, 100+: external zones

--create output table
drop table if exists level2_zones;
create table level2_zones(id SERIAL PRIMARY KEY, pruid integer, cduid integer, cmauid integer, description varchar, zone_type integer, metro integer, ext_zone_id integer);
SELECT AddGeometryColumn('level2_zones', 'geom', 4269, 'MULTIPOLYGON', 2);

INSERT INTO level2_zones (pruid, cduid, cmauid, description, zone_type, metro, geom)
	SELECT pruid, cduid, cmauid, cdname || ' -- CMA of  ' || cmaname, 0, 1, geom
	FROM temp_cd_cma_intersection
UNION
--get remaining areas of census divisions as the remainding zones
	SELECT CAST(cd.pruid as INTEGER), CAST(cd.cduid as INTEGER), 0, cd.cdname, 0, 0,
		ST_Multi(COALESCE(ST_Difference(cd.geom, cdcma.geom), cd.geom)) as geom
	FROM census_divisions as cd
	left join temp_cd_cma_intersection as cdcma on CAST(cd.cduid as integer) = cdcma.cduid
	where cd.pruid = '35' and GeometryType(COALESCE(ST_Difference(cd.geom, cdcma.geom), cd.geom)) != 'GEOMETRYCOLLECTION'
order by cduid;

--add canadian province zones
INSERT INTO level2_zones (pruid, cduid, cmauid, description, zone_type, metro, ext_zone_id, geom)
SELECT CAST(key as INTEGER), 0, 0, description, 1, metro_region, zone_id, geom
from external_zones_v2
where label like 'PR%';

--add canadian cma zones
INSERT INTO level2_zones (pruid, cduid, cmauid, description, zone_type, metro, ext_zone_id, geom)
SELECT CAST(substring(key, 0, 3) as INTEGER), 0, CAST(substring(key, 3,5) as INTEGER), description, 1, metro_region, zone_id, geom
from external_zones_v2
where label like 'CMA%';

--add american zones
INSERT INTO level2_zones (pruid, cduid, cmauid, description, zone_type, metro, ext_zone_id, geom)
SELECT 0, 0, 0, description, 2, metro_region, zone_id, geom
from external_zones_v2
where label like 'F3%';

drop table temp_cd_cma_intersection;

select * from level2_zones order by id;

