--create mapping from pr, cd, cma to zone_lvl2
DROP TABLE IF EXISTS zone_lvl2; 
CREATE TABLE zone_lvl2(pr integer, cd integer, cma integer, zone_lvl2 numeric);

--add internal zones
insert into zone_lvl2
select CAST(pruid as integer), CAST(cduid as integer), NULL, CAST(cduid as integer)
from census_divisions
where pruid = '35';

--add external cma zones
--add external pr zones
insert into zone_lvl2
select 	case when cma_pr_code < 100 then cma_pr_code else NULL end, 
	NULL, 
	case when cma_pr_code > 100 then cma_pr_code else NULL end, 
	zone_id
from pop_jobs_data_canada;

CREATE INDEX zone_lvl2_idx on zone_lvl2(pr, cd, cma);

select * from zone_lvl2;

