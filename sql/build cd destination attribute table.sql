DROP TABLE IF EXISTS destination_attributes;

SELECT pa.*, z.metro
INTO destination_attributes
from (
	SELECT zone_lvl2, sum(population) as population, sum(total_employment) as employment,
			sum(naics_11) as naics_11,sum(naics_21) as naics_21,sum(naics_22) as naics_22,
			sum(naics_23) as naics_23,sum(naics_31) as naics_31,sum(naics_41) as naics_41,
			sum(naics_44) as naics_44,sum(naics_48) as naics_48,sum(naics_51) as naics_51,
			sum(naics_52) as naics_52,sum(naics_53) as naics_53,
			sum(naics_54) as naics_54, sum(naics_55) as naics_55,sum(naics_56) as naics_56,
			sum(naics_61) as naics_61,sum(naics_62) as naics_62,sum(naics_71) as naics_71,
			sum(naics_72) as naics_72,sum(naics_81) as naics_81,sum(naics_91) as naics_91
			FROM public.canada_production_attraction
			group by zone_lvl2
			order by zone_lvl2
	) as pa
JOIN zone_lvl2 as z on pa.zone_lvl2 = z.zone_lvl2;

select * from destination_attributes;
