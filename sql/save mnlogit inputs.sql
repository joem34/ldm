--need to add NETWORK SERVICE as a read/write user to the data folder

copy (
select id, mrdtrip2, lvl2_orig, lvl2_dest, incomgr2, orig_is_metro, dest_is_metro, wtep
from tsrc_trip
) to 'C:/Users/Joe/canada/data/mnlogit/mnlogit_all_trips2.csv' WITH CSV HEADER;

copy (
select *
from destination_attributes
) to 'C:/Users/Joe/canada/data/mnlogit/mnlogit_canada_alternatives2.csv' WITH CSV HEADER;




