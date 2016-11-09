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

copy (
select id, purpose, season, lvl2_orig, lvl2_dest, incomgr2, orig_is_metro, dest_is_metro, wtep
from tsrc_trip
where not(orcprovt != 35 and orcprovt = mddplfl) --eclude external intra province trips
) to 'C:/Users/Joe/canada/data/mnlogit/mnlogit_trips_no_intra_province.csv' WITH CSV HEADER;




copy (
select *
from destination_attributes
) to 'C:/Users/Joe/canada/data/mnlogit/mnlogit_canada_alternatives2.csv' WITH CSV HEADER;




