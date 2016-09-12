CREATE TABLE tsrc_person(
  id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
  refyearp integer,
  refmthp integer,
  pumfid integer,
  wtpm DECIMAL(16,4),
  wtpm2 DECIMAL(16,4),
  resprov integer,
  rescd2 integer,
  rescma2 integer,
  age_gr2 integer,
  sex integer,
  edlevgr integer,
  lfsstatg integer,
  incomgr2 integer,
  g_adults integer,
  g_kids integer,
  trip_cnt integer,
  on_cnt integer,
  sd_cnt integer,
  tripctot integer
);

CREATE TABLE tsrc_trip
(

  
id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
  
refyear integer,
  
refmth integer,
  
pumfid integer,
  
tripid integer,
  
quarter integer,

orcprovt integer,

orccdt2 integer,

orccmat2 integer,

mddplfl integer,

mdccd integer,

mdccma2 integer,

wtep DECIMAL(16,4),
  
wttp DECIMAL(16,4),

age_gr2 integer,

sex integer,

edlevgr integer,

lfsstatg integer,

incomgr2 integer,

tp_d01 integer,

t_g0802 integer,

tr_g08 integer,

tp_g02 integer,

mrdtrip2 integer,

mrdtrip3 integer,

dist2 integer,

tmdtype2 integer,

cannite integer,

trip_cnt integer,

tripctot integer, 

tr_d11 integer,

triptype integer
);

SELECT AddGeometryColumn('tsrc_trip', 'geom', 4269, 'LINESTRING', 2);