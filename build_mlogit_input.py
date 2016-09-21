import psycopg2
import random
import csv
# Connect to an existing database
conn = psycopg2.connect("dbname=canada user=postgres")

# Open a cursor to perform database operations


cur = conn.cursor()
cur.execute("SELECT id, lvl2_orig, lvl2_dest, incomgr2, age_gr2, edlevgr, wttp from tsrc_trip where lvl2_orig < 4000 or lvl2_dest < 4000;")

trips = cur.fetchall()

dest_zones = "9793, 3557, 3531, 3507, 3540, 9753"
#dest_zones = "3557, 3531"

#get all destination alternatives
cur.execute("""SELECT zone_lvl2, sum(production) as production, sum(attraction) as attraction
                FROM public.canada_production_attraction
                WHERE zone_lvl2 in (%s)
                group by zone_lvl2;""" % dest_zones)


alternatives = cur.fetchall()
alternative_list = [a[0] for a in alternatives]
print alternative_list

cur.execute("""select a.zone_id, b.zone_id, ST_Distance(ST_Transform(ac, 26917), ST_Transform(bc, 26917))/1000 as dist from (
                select CAST(cduid AS integer) as zone_id, ST_Centroid(geom) as ac from census_divisions where pruid = '35'
                union
                select zone_id, ST_Centroid(geom) from external_zones_v2
            ) as a,
             (
                select CAST(cduid AS integer) as zone_id, ST_Centroid(geom) as bc from census_divisions where pruid = '35'
                union
                select zone_id, ST_Centroid(geom) from external_zones_v2 where zone_id in (%s)
            ) as b""" % (dest_zones))
od_matrix = {(a[0],a[1]): a[2] for a in cur.fetchall()}

with open("C:/mto_longDistanceTravel/mlogit/mlogit_trip_input_small.csv", 'w') as out:
    csvwriter = csv.writer(out)
    headers = ["trip_id", "choice", "origin", "dest", "income", "age", "education", "weight", "production", "attraction", "dist"]
    csvwriter.writerow(headers)
    print headers
    used_destinations = set()
    for t in trips:
        trip_dest = t[2]
        trip_origin = t[1]
        for a in alternatives:
            if trip_dest in alternative_list:# and trip_origin in alternative_list:
                used_destinations.add(trip_dest)
                alt_dest = a[0]
                chosen = alt_dest == trip_dest
                dist = od_matrix[(trip_origin, alt_dest)]
                if chosen:
                    row = [t[0], chosen, trip_origin, alt_dest, t[3], t[4], t[5], t[6], a[1], a[2], dist]
                else:
                    row = [t[0], chosen, trip_origin, alt_dest, t[3], t[4], t[5], 0, a[1], a[2], dist]

                csvwriter.writerow(row)

            #if trip_dest in alternative_list: print t, a, chosen
    print used_destinations

with open("C:/mto_longDistanceTravel/mlogit/mlogit_trip_input.csv", 'w') as out:
    csvwriter = csv.writer(out)
    headers = ["trip_id", "choice", "origin", "dest", "income", "age", "education", "weight", "production", "attraction", "dist"]
    csvwriter.writerow(headers)
    print headers
    used_destinations = set()
    for t in trips:
        trip_dest = t[2]
        trip_origin = t[1]
        for a in alternatives:
            if trip_dest in alternative_list:# and trip_origin in alternative_list:
                used_destinations.add(trip_dest)
                alt_dest = a[0]
                chosen = alt_dest == trip_dest
                dist = od_matrix[(trip_origin, alt_dest)]
                if chosen:
                    row = [t[0], chosen, trip_origin, alt_dest, t[3], t[4], t[5], t[6], a[1], a[2], dist]
                else:
                    row = [t[0], chosen, trip_origin, alt_dest, t[3], t[4], t[5], 0, a[1], a[2], dist]

                csvwriter.writerow(row)

            #if trip_dest in alternative_list: print t, a, chosen
    print used_destinations