import json
import unicodecsv as csv
import os
from collections import defaultdict
import itertools

def filter_venues(top_5_categories_for_search, category, search_cat_id, num_checkins):
    should_write = True
    outdoor_categories = {"Beach", "Other Great Outdoors", "Scenic Lookout", "Trail",
             "Campground", "National Park", "Farm", "Island", "Mountain",
             "Lighthouse", "Waterfall", "Nature Preserve", "Forest", "lake", "river"}

    if search_cat_id == '4d4b7105d754a06377d81259' and category not in outdoor_categories:
        should_write = False
    if num_checkins == 0:
        should_write = False
    if category not in top_5_categories_for_search:
        should_write = False
    return should_write






fs_folder = "../../data/foursquare/"
venues_folder = os.path.join(fs_folder, "by_category")

venues = {}
for f in os.listdir(venues_folder):
    print f
    if f.startswith("venues_"):
        with open(os.path.join(venues_folder, f)) as fo:
            venue_cat = os.path.splitext(f)[0].split('_')[-1]
            venues[venue_cat] = []
            print venue_cat
            responses = json.load(fo)
            for vs in [r['venues'] for r in responses.itervalues()]:
                venues[venue_cat].extend(vs)

print len(venues)

with open(os.path.join(venues_folder,"all_venues.csv"), 'wb') as out:
    csvwriter = csv.writer(out, encoding='utf-8')
    csvwriter.writerow(["venue_id", "name", "country", "state",
                        "lon", "lat", "category_name", "category_id", "search_cat_name", "tips", "users", "checkins"])
    for cat in venues:
        for v in venues[cat]:
            try:
                venue_id = v['id']
                venue_name = v['name']

                country =  v['location']['country'] if 'country' in v['location'] else ''

                state = v['location']['state'] if 'state' in v['location'] else ''

                lon = v['location']['lng']
                lat = v['location']['lat']

                if len(v['categories']) > 0:
                    category_name = v['categories'][0]['name']
                    category_id = v['categories'][0]['id']
                else:
                    category_name = ''
                    category_id = ''

                tips = v['stats']['tipCount']
                users = v['stats']['usersCount']
                checkins = v['stats']['checkinsCount']

                csvwriter.writerow([venue_id, venue_name, country, state, lon, lat, category_name,
                                       category_id, cat, tips, users, checkins])
            except KeyError:
                print v
                exit()
