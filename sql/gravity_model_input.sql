--gravity model input by purpose, as cd level
select t.zone_id, zone_type, purpose, sum(production) as production, sum(population + employment) as attraction
from destination_attributes, 
	(
		select lvl2_orig as zone_id, 
			case when lvl2_orig < 70 then 'I' else 'E' end as zone_type,
			purpose, wtep as production
		from tsrc_trip
		where purpose != 'other'
		) as t
where t.zone_id = alt
group by t.zone_id, zone_type, purpose
order by t.zone_id, purpose
