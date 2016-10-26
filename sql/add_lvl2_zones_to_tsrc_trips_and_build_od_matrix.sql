--update trips with lvl2 origin and destination zones
ALTER TABLE tsrc_trip ADD COLUMN lvl2_orig integer;
ALTER TABLE tsrc_trip ADD COLUMN lvl2_dest integer;
ALTER TABLE tsrc_trip ADD COLUMN orig_is_metro integer;
ALTER TABLE tsrc_trip ADD COLUMN dest_is_metro integer;
ALTER TABLE tsrc_trip ADD COLUMN is_summer integer;

--is trip winter or summer, as set by Sundar
update tsrc_trip
SET is_summer = 1 - CAST(refmth < 4 or refmth > 10 as integer);

update tsrc_trip
SET season = case when is_summer = 1 then 'summer' else 'winter' end


--set a metro or not metro flag. #TODO; this will need to be calculated differently for generated trips
update tsrc_trip
SET orig_is_metro = case when orccmat2 > 0 then 1
			else 0 end,
    dest_is_metro = case when mdccma2 > 0 then 1
			else 0 end;

update tsrc_trip
SET lvl2_orig = NULL, lvl2_dest = NULL	;		

--SET origin lvl 2 zone for internal origin and external cmas
update tsrc_trip
SET lvl2_orig = o.id
from level2_zones as o
where (orcprovt = 35 and orccdt2 = o.cduid and orccmat2 = o.cmauid) 
	or (orcprovt <> 35 and (orccmat2 = o.cmauid and orcprovt = o.pruid));
	
--SET origin lvl 2 zone for external provinces
update tsrc_trip
SET lvl2_orig = o.id
from level2_zones as o
where lvl2_orig is NULL AND (orcprovt <> 35 and (orcprovt = o.pruid));

--SET destination lvl 2 zone for internal origin and external cmas
update tsrc_trip
SET lvl2_dest = d.id
from level2_zones as d
where (mddplfl = 35 and mdccd = d.cduid and mdccma2 = d.cmauid) 
	or (mddplfl <> 35 and (mdccma2 = d.cmauid and mddplfl = d.pruid));
	
--SET destination lvl 2 zone for external provinces
update tsrc_trip
SET lvl2_dest = d.id
from level2_zones as d
where lvl2_dest is NULL AND (mddplfl <> 35 and (mddplfl = d.pruid));


--remove any trips that  are in ontario but dont have a origin/dest cd
delete from tsrc_trip
where (orcprovt = 35 and orccdt2 = 9999) or (mddplfl = 35 and mdccd = 9999)

--build lvl2 od matrix from trips

DROP TABLE IF EXISTS public.tsrc_lvl2_od_matrix;

SELECT t.lvl2_orig AS lvl2_orig,
    t.lvl2_dest AS lvl2_dest, t.purpose, t.refyear,
    sum(t.wtep) / 365::numeric AS trips
INTO public.tsrc_lvl2_od_matrix
FROM public.tsrc_trip as t
WHERE t.dist2 < 9999
GROUP BY t.lvl2_orig, t.lvl2_dest, t.purpose, t.refyear
ORDER BY t.lvl2_orig, t.lvl2_dest, t.purpose, t.refyear;

  select * from public.tsrc_lvl2_od_matrix;

--create table for gravity model results
--process
	--x, ex, x1= x*scaling_factor, abs=abs(x*scaling_factor - ex), rel = x*scaling_factor/abs
	--scaling factor = tsrc_trips/gen_trips (trip_gen) (not necessary if we use the tsrc data)
