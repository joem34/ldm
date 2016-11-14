--need to add NETWORK SERVICE as a read/write user to the data folder

copy (
select id, purpose, season, lvl2_orig, lvl2_dest, incomgr2, orig_is_metro, dest_is_metro, wtep
from tsrc_trip
) to 'C:/Users/Joe/canada/data/mnlogit/mnlogit_all_trips2.csv' WITH CSV HEADER;

copy (
select id, purpose, season, lvl2_orig, lvl2_dest, incomgr2, orig_is_metro, dest_is_metro, wtep
from tsrc_trip
where not(lvl2_orig = lvl2_dest and lvl2_orig < 70 and dist2 <=40)
) to 'C:/Users/Joe/canada/data/mnlogit/mnlogit_no_intra.csv' WITH CSV HEADER;

copy (
select id, purpose, season, lvl2_orig, orcprovt as orig_pr, lvl2_dest, mddplfl as dest_pr, tmdtype2, dist2, incomgr2, orig_is_metro, dest_is_metro, wtep
from tsrc_trip
) to 'C:/Users/Joe/canada/data/mnlogit/mnlogit_trips_more_variables.csv' WITH CSV HEADER;

select id, purpose, season, lvl2_orig, lvl2_dest, orcprovt as orig_pr, mddplfl as dest_pr, incomgr2, orig_is_metro, dest_is_metro, wtep
into tsrc_trip_filtered
from tsrc_trip
where (((orcprovt <= 35 and mddplfl >= 35) or (orcprovt >= 35 and mddplfl <= 35)) --eclude external intra province trips,
	and not (lvl2_orig = lvl2_dest and tmdtype2 = 2) --exclude internal zone air trips
	and not (((orcprovt <> 35 and mddplfl <> 35) or (orcprovt <> 35 and mddplfl <> 35)) and tmdtype2 = 2)) -- remove air trips that dont enter ontario\
      or (orcprovt = 24 and mddplfl = 24 and (lvl2_orig in (85, 117) or lvl2_dest in (85, 117)));

copy (
select * from tsrc_trip_filtered
) to 'C:/Users/Joe/canada/data/mnlogit/mnlogit_trips_no_intra_province.csv' WITH CSV HEADER;

copy (
select *
from destination_attributes
) to 'C:/Users/Joe/canada/data/mnlogit/mnlogit_canada_alternatives2.csv' WITH CSV HEADER;

