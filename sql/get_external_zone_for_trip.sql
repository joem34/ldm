select t.id, t.orcprovt, t.orccmat2,  t.mddplfl, t.mdccma2, e.ID as o_zone, d.ID as d_zone
from tsrc_trip as t, canadian_external_zone_codes as e, canadian_external_zone_codes as d
where 
		case 
			when t.orccmat2 in (
					select Province_or_cma from canadian_external_zone_codes where Type='CMA'
					) then  t.orccmat2 = e.Province_or_cma
			else t.orcprovt = e.Province_or_cma 
		END
		and
		case 
			when t.mdccma2 in (
					select Province_or_cma from canadian_external_zone_codes where Type='CMA'
					) then  t.mdccma2 = d.Province_or_cma
			else t.mddplfl = d.Province_or_cma 
		END
	and t.orcprovt <> 35 and o_zone <> d_zone