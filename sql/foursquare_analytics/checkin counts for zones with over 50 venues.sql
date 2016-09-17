--select all zones that have 50 venues
select z.id, count(1) as num_venues, sum(v.checkins) as num_checkins, min(v.checkins) as min_checkins
from internal_zones as z, fs_venues as v
where ST_Within(v.geom, z.geom)
group by z.id
Having count(1) >= 50
order by min(v.checkins) desc

--for these zones, select the venue with the minimum count and minimum checkins