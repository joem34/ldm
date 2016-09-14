import json
import csv
venues = {}
files = ['20160913-181900', '20160914-005416']
for date in files:
    with open("output/venues_%s.json" % date) as f:
        venues.update(json.load(f))

print len(venues)
count_50 = 0
with open("output/zone_venue_stats.csv", 'w') as out:
    csvwriter = csv.writer(out)
    csvwriter.writerow(["zone_id", "venue_count", "checkin_count"])
    for (zone, vs) in venues.iteritems():
        if len(vs) == 50:
            count_50 += 1
            print (zone, len(vs))
            csvwriter.writerow([zone, len(vs), sum([v['stats']['checkinsCount'] for v in vs])])

print count_50