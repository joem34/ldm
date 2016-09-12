
select g.dest, sum(x) as trips, sum(ex) as trips_ex, sum(abs_err) as absolute_error, sum(rel_err) as relative_error, o.cdname
from gravity_model_errors as g, census_divisions as o
where g.dest = cast(o.cduid as integer)
group by g.dest, o.cdname, o.geom
order by g.dest asc
