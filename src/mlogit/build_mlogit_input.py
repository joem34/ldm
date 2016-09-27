import psycopg2
import psycopg2.extras
import random
import csv
# Connect to an existing database
conn = psycopg2.connect("dbname=canada user=postgres")

#get the list of trips

#need an OD matrix between all zones -> cd to central zone mapping?

#get the list of alternatives

#build a long list of alternatives for each trip, either all alternatives or a sample

#assert that there is a trip for every alternative


cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
#TODO: exclude non-stated from trips
cur.execute("SELECT id, mrdtrip2, lvl2_orig, lvl2_dest, incomgr2, age_gr2, edlevgr, wttp, orig_is_metro, dest_is_metro from tsrc_trip where lvl2_orig < 4000 or lvl2_dest < 4000 and refyear = 2014;")

trips = cur.fetchall()

dest_zones = "9793, 3557, 3531, 3507, 3540, 9753"
dest_zones = ",".join(set([str(t['lvl2_dest']) for t in trips]))
#dest_zones = ",".join(set([str(t['lvl2_dest']) for t in trips][:20]))
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
    headers = ["chid", "choice", "alt", "purpose", "weight", "income", "population", "employment", "dist", "mm", "mr", "rm", "rr"]

    naics_headers = ("naics_11,naics_21,naics_22,naics_23,naics_31,naics_41,naics_44,naics_48,naics_51,naics_52,naics_53,naics_54,"  +
			        "naics_55,naics_56,naics_61,naics_62,naics_71,naics_72,naics_81,naics_91").split(",")

    headers.extend(naics_headers)

    csvwriter.writerow(headers)
    print headers
    used_destinations = set()

    chid = 1
    for t in trips:
        trip_dest = t['lvl2_dest']
        trip_origin = t['lvl2_orig']

        weight = t['wttp']
        age = t['age_gr2']
        income = t['incomgr2']
        education = t['edlevgr']
        income1 = int(income == 1)
        income2 = int(income == 2)
        income3 = int(income == 3)
        income4 = int(income == 4)
        purpose = t['mrdtrip2']

        metro_to_metro = int(t['orig_is_metro'] == 1 and t['dest_is_metro'] == 1)
        metro_to_regional = int(t['orig_is_metro'] == 1 and t['dest_is_metro'] == 0)
        regional_to_metro = int(t['orig_is_metro'] == 0 and t['dest_is_metro'] == 1)
        regional_to_regional = int(t['orig_is_metro'] == 0 and t['dest_is_metro'] == 0)

        for a in alternatives:
            if trip_dest in alternative_list:# and trip_origin in alternative_list:
                used_destinations.add(trip_dest)
                alt_dest = a['zone_lvl2']
                chosen = alt_dest == trip_dest
                population = a['population']
                employment= a['employment']
                metro = 1 if a['metro'] else 0
                dist = od_matrix[(trip_origin, alt_dest)]

                row = [chid, chosen, alt_dest, purpose, weight, income, population, employment, dist, metro_to_metro, metro_to_regional, regional_to_metro, regional_to_regional]
                row.extend([a[x] for x in naics_headers])
                csvwriter.writerow(row)
        chid += 1
            #if trip_dest in alternative_list: print t, a, chosen
    print used_destinations

    #best way to build a table of alternatives?

def convert_to_dummy_variable():
    pass