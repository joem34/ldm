--update trips with lvl2 origin and destination zones

update tsrc_trip
SET lvl2_orig = o.zone_lvl2
from zone_lvl2 as o
where (orcprovt = 35 and orccdt2 = o.cd) or (orcprovt <> 35 and (orccmat2 = o.cma or orcprovt = o.pr));

update tsrc_trip
SET lvl2_dest = d.zone_lvl2
from zone_lvl2 as d
where (mdccd = d.cd and mddplfl = 35) or (orcprovt <> 35 and (mdccma2 = d.cma or mddplfl = d.pr));

--build lvl2 od matrix from trips

 DROP VIEW public.tsrc_cd_od_matrx_2014;

CREATE OR REPLACE VIEW public.tsrc_cd_od_matrx_2014 AS 
 SELECT t.lvl2_orig AS lvl2_orig,
    t.lvl2_dest AS lvl2_dest,
    sum(t.wttp) / 365::numeric AS trips
   FROM tsrc_trip t
  WHERE 
	t.refyear = 2014 
	AND (
		(t.lvl2_orig / 100 = 35) 
		or 
		(t.lvl2_orig > 4000 AND t.lvl2_dest / 100 = 35)
	)
  --and t.mddplfl = 35 -- for the moment, only take internal trips. We need to group external canada trips seperately by pr/cma
  GROUP BY t.lvl2_orig, t.lvl2_dest
  ORDER BY t.lvl2_orig, t.lvl2_dest;

--create table for gravity model results
DROP TABLE IF EXISTS gravity_model_results; 
CREATE TABLE gravity_model_results(orig integer, dest integer, trips numeric);

DROP VIEW IF EXISTS gravity_model_errors;
CREATE OR REPLACE VIEW gravity_model_errors as
	select 
		orig, dest, round(x, 3) as x, round(ex, 3) as ex, 
		case when orig < 4000 and dest < 4000 then 'II'
                         when orig < 4000 and dest > 4000 then 'IE'
                         when orig > 4000 and dest < 4000 then 'EI'
                         else 'EE' end as od_type,
		round(abs(x - ex), 3) as abs_err, round(COALESCE(abs(x - ex)/NULLIF(ex,0), 0), 3) as rel_err
	from (
		select coalesce(orig, lvl2_orig) as orig, coalesce(dest, lvl2_dest) as dest, 
		coalesce(g.trips, 0) as x, coalesce(t.trips, 0) as ex
		from gravity_model_results as g 
			full join tsrc_cd_od_matrx_2014 as t 
			on t.lvl2_orig = orig and t.lvl2_dest = dest
	) as r
	where x > 0 or ex > 0
	order by orig asc, dest asc;

select * from gravity_model_errors;

DROP TABLE IF EXISTS gravity_model_err_spatial;
CREATE TABLE gravity_model_err_spatial as
select g.*, abs_err * rel_err as "a*r", o.cdname as o_cdname, d.cdname as d_cdname, ST_MakeLine(ST_Centroid(o.geom), ST_Centroid(d.geom)) as geom
from gravity_model_errors as g, census_divisions as o, census_divisions as d
where 	abs_err > 250 and rel_err > 10
	and cast(o.cduid as integer) = orig
	and cast(d.cduid as integer) = dest
order by abs_err * rel_err desc
limit 20;

select Populate_Geometry_Columns(); -- need this to be able to load geometries into qgis

