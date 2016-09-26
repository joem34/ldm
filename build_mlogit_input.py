import psycopg2
import psycopg2.extras
import random
import csv
# Connect to an existing database
conn = psycopg2.connect("dbname=canada user=postgres")

# Open a cursor to perform database operations


cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
#TODO: exclude non-stated from trips
cur.execute("SELECT id, lvl2_orig, lvl2_dest, incomgr2, age_gr2, edlevgr, wttp from tsrc_trip where lvl2_orig < 4000 or lvl2_dest < 4000;")

trips = cur.fetchall()

dest_zones = "9793, 3557, 3531, 3507, 3540, 9753"
dest_zones = ",".join(set([str(t['lvl2_dest']) for t in trips]))
print dest_zones
#dest_zones = "3557, 3531"

#get all destination alternatives
cur.execute("""SELECT * from destination_attributes where zone_lvl2 in (%s)""" % dest_zones)


alternatives = cur.fetchall()
alternative_list = [a['zone_lvl2'] for a in alternatives]
print alternative_list


cur.execute("""select a.zone_id as o, b.zone_id as d, ST_Distance(ST_Transform(ac, 26917), ST_Transform(bc, 26917))/1000 as dist from (
                select CAST(cduid AS integer) as zone_id, ST_Centroid(geom) as ac from census_divisions where pruid = '35'
                union
                select zone_id, ST_Centroid(geom) from external_zones_v2
            ) as a,
             (
                select CAST(cduid AS integer) as zone_id, ST_Centroid(geom) as bc from census_divisions where pruid = '35'
                union
                select zone_id, ST_Centroid(geom) from external_zones_v2 where zone_id in (%s)
            ) as b""" % (dest_zones))
od_matrix = {(a['o'],a['d']): a['dist'] for a in cur.fetchall()}

out_location = "C:/mto_longDistanceTravel/mlogit/mlogit_trip_input_dummies_%d.csv" % len(alternative_list)
print out_location
with open(out_location, 'w') as out:
    csvwriter = csv.writer(out)
    headers = ["chid", "choice", "alt", "weight", "income", "income1", "income2", "income3", "income4", "population", "employment", "dist"]
    csvwriter.writerow(headers)
    print headers
    used_destinations = set()

    chid = 1
    for t in trips:
        trip_dest = t['lvl2_dest']
        trip_origin = t['lvl2_orig']
        for a in alternatives:
            if trip_dest in alternative_list:# and trip_origin in alternative_list:
                used_destinations.add(trip_dest)
                alt_dest = a['zone_lvl2']
                chosen = alt_dest == trip_dest
                dist = od_matrix[(trip_origin, alt_dest)]
                weight = t['wttp']
                age = t['age_gr2']
                income = t['incomgr2']
                education = t['edlevgr']
                income1 = int(income == 1)
                income2 = int(income == 2)
                income3 = int(income == 3)
                income4 = int(income == 4)

                row = [chid, chosen, alt_dest, weight, income, income1, income2, income3, income4, a['population'], a['employment'], dist]
                csvwriter.writerow(row)
        chid += 1
            #if trip_dest in alternative_list: print t, a, chosen
    print used_destinations

    #best way to build a table of alternatives?

def convert_to_dummy_variable():
    pass