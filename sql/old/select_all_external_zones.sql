DROP VIEW IF EXISTS zones_pop_emp_type;
CREATE VIEW zones_pop_emp_type AS
SELECT 	zone_id, 
	domesticVisit + domesticBusiness + domesticLeisure as production, 
	population + employment as attraction, 1 as zone_type
FROM generated_trips

UNION

SELECT 	zone_id, 
	0, 
	population + total_employment, 
	case when cma_pr_code < 100 then 2 else 3 end as zone_type
  FROM public.pop_jobs_data_canada
  where cma_pr_code < 900

  UNION

SELECT 	zone_id, 0, 
	population + total_employment,
	4 as zone_type
  FROM public.pop_jobs_data_us

  order by zone_id