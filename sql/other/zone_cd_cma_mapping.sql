select row_number() OVER (ORDER BY cd_cma_zone) AS i,
  cd_cma_zone, count(1) from (
	select o.id, z2.id, z2.cduid, z2.cmauid, case when z2.cmauid > 0 then z2.cmauid else z2.cduid end as cd_cma_zone
	from ontario_zones as o, level2_zones as z2
	where o.cd = z2.id
) as r
group by cd_cma_zone
