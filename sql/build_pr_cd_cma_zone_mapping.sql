DROP VIEW pr_cd_cma_zone_mapping;

CREATE VIEW pr_cd_cma_zone_mapping AS
select 
	null as pr, 
	CDUID as cd, 
	null as cma, 
	ID as zone 
from cd_centroids_central_zone

union 

select 
	case when Type = 'PR' then Province_or_cma ELSE null END, 
	null, 
	case when Type = 'CMA' then Province_or_cma ELSE null END,  
	ID
from canadian_external_zone_codes