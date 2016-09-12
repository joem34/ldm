select sum(dist2*wttp)/sum(wttp) as avg_trip_length_wttp, sum(dist2*wtep)/sum(wtep) as avg_trip_length_wtep
from tsrc_trip
where (orcprovt = 35 or mddplfl = 35) and dist2 < 99999