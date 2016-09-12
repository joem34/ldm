create view tsrc_cd_od_matrx_2014 as 
select 
	t.orccdt2 as orig_cd, t.mdccd as dest_cd,
	sum(t.wttp)/365 as n_per_day, 
from tsrc_trip as t 
where t.refyear = 2014 and t.orcprovt = 35 and t.mddplfl = 35
group by orig_cd, dest_cd
order by orig_cd, dest_cd asc

--want to mark trips as II, IE, EI