select lvl2_orig, cast(tsrc_trips as integer), cast(gen_trips as integer), cast(model_trips as integer)
from (
	
	select 	lvl2_orig, sum(trips) as tsrc_trips
	from tsrc_cd_od_matrx_2014 as t 
	group by t.lvl2_orig
	order by t.lvl2_orig
) as a, (
	select orig, sum(trips) as model_trips 
	from gravity_model_results 
	group by orig
	order by orig
) as b, (

select 	zone_lvl2,
		sum(production) as gen_trips
	from 	canada_production_attraction
	--where zone_id < 7060
	group by zone_lvl2
	order by zone_lvl2
) as c
where a.lvl2_orig = b.orig and a.lvl2_orig = c.zone_lvl2