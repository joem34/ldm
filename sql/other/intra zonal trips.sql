select lvl2_orig, lvl2_dest, orig_is_metro as metro, sum(wtep) as trips, ST_astext(z.geom)
from tsrc_trip
left join level2_zones as z on lvl2_orig = z.id
where lvl2_orig = lvl2_dest and lvl2_orig < 70
group by lvl2_orig, lvl2_dest, orig_is_metro, ST_astext(z.geom)