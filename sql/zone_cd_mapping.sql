drop table if exists zone_cd_mapping;
drop table if exists temp_zone_cd_mapping;

select o.id as zone, CAST(cd.cduid as INTEGER) as zone_lvl2
into temp_zone_cd_mapping
from ontario_zones  as o, census_divisions as cd
WHERE CAST (cd.pruid AS INTEGER) = 35 and ST_Intersects(ST_Centroid(o.geom), cd.geom);


CREATE TABLE zone_cd_mapping as
select o.id as zone, CAST(cd.cduid as INTEGER) as zone_lvl2
from ontario_zones  as o, census_divisions as cd
WHERE CAST (cd.pruid AS INTEGER) = 35 
	and o.id not in (select zone from temp_zone_cd_mapping)
	and ST_Intersects(o.geom, cd.geom) 

UNION

select * from temp_zone_cd_mapping
order by zone;

--fill in census divisions for silly zones that don't overlap with any cd's
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3538 ,57);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3510 ,380);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3520 ,1652);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3520 ,2080);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3520 ,3156);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3520 ,3157);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3501 ,3168);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3518 ,3195);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3510 ,3219);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3558 ,3222);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3538 ,3248);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3524 ,3253);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3524 ,3256);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3521 ,3260);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3521 ,3272);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3525 ,3274);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3520 ,3281);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3537 ,3310);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3537 ,3325);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3537 ,3328);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3537 ,3332);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3520 ,3363);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3518 ,3367);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3518 ,3368);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3537 ,3377);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3537 ,3378);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3521 ,3386);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3521 ,3387);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3524 ,3390);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3524 ,3392);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3510 ,3418);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3526 ,3439);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3526 ,3440);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3520 ,3462);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3501 ,3455);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3526 ,3468);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3543 ,3482);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3542 ,3498);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3543 ,3499);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3543 ,3500);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3541 ,3502);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3526 ,3509);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3526 ,3510);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3526 ,3511);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3526 ,3533);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3526 ,3534);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3526 ,3562);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3526 ,3563);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3537 ,3571);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3514 ,3576);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3514 ,3578);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3537 ,3581);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3534 ,3592);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3534 ,3595);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3541 ,3621);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3526 ,3630);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3528 ,3632);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3528 ,3633);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3558 ,4047);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3558 ,4048);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3558 ,4049);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3558 ,4068);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3558 ,4088);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3551 ,4144);
INSERT INTO zone_cd_mapping  (zone_lvl2, zone) VALUES (3537 ,4280);


update ontario_zones as o
set cd = z.zone_lvl2
from zone_cd_mapping as z 
where o.id = z.zone;


drop table if exists zone_cd_mapping;
drop table if exists temp_zone_cd_mapping;