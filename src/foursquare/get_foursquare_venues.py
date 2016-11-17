import time
import string
import foursquare
import json
import csv
from fiona import collection
from fiona.crs import to_string
from functools import partial
import pyproj
from pyproj import Proj
from shapely.ops import transform
from shapely.geometry import shape

from math import cos, sin, asin, sqrt, radians


def calc_distance(lat1, lon1, lat2, lon2):
    """
    Calculate the great circle distance between two points
    on the earth (specified in decimal degrees)
    """
    # convert decimal degrees to radians
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    # haversine formula
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(dlon / 2) ** 2
    c = 2 * asin(sqrt(a))
    km = 6371 * c
    return km

timer = 0
program_start_time = time.time()


import time
def call_api():
    api_rate = 5000
    start = time.time()

    #call api here...
    response = None

    end = time.time()
    delay = max((3600.0)/api_rate - (end-start), 0)
    #print "api call took %.2f seconds, wait %.2f" % (end-start, delay)
    time.sleep(delay)
    return response

def call_venue_api(client, zone_id, north, east, south, west, categories = None):
    start = time.time()
    ne = str(north) + ',' +  str(east)
    sw = str(south) + ',' +  str(west)

    params={'intent':'browse', 'ne': ne, "sw":sw , 'limit':100}
    if categories: params.update({'categoryId':categories})

    y = calc_distance(west, north, west,  south)
    x = calc_distance(west, north, east,  north)

    venues = client.venues.search(params=params)
    #print (zone_id, params['sw'], params['ne'], x*y)
    response = {
        "bbox": {"n": north, "s": south, "e": east, "w": west},
        "venues": venues['venues']
    }
    end = time.time()
    delay = max((3600.0)/5000.0 - (end-start), 0)
    #print "api call took %.2f seconds, wait %.2f" % (end-start, delay)
    time.sleep(delay)
    return response


def get_venues_for_zones(client, zones, categories=None):
    print "running for:", categories
    zones_crs = Proj(to_string(zones.crs))
    fs_crs = Proj(init='epsg:4269')
    project = partial(pyproj.transform, zones_crs, fs_crs) # destination coordinate system

    all_venues = {}
    #TODO!!!!!!!!!!!!!! hawaii
    try:
        i = 0
        for poly in zones:
            poly1 = transform(project, shape(poly['geometry']))  # apply projection
            bbox = poly1.bounds
            (west, south, east, north) = tuple(bbox)

            y = calc_distance(west, north, west, south)
            x = calc_distance(west, north, east, north)

            # print params
            # if north < nl and east < el and south > sl and west > wl:
            zone_id = int(poly['properties']["ID"])
            # if north > 44 or True:
            all_venues[zone_id] = {}
            try:
                response = call_venue_api(client, zone_id, north, east, south, west, categories)
                all_venues[zone_id].update(response)
            except (foursquare.GeocodeTooBig) as e:
                print (zone_id, ":", " too big", y * x)

            i += 1
            if i % 100 == 0: print (time.time() - program_start_time) / 60, i
    except (foursquare.ParamError, foursquare.EndpointError) as e:
        print e
        exit()

    finally:
        with open("data/foursquare/venues_%s_%s.json" % (time.strftime("%Y%m%d-%H%M%S"), categories), 'w') as out:
            json.dump(all_venues, out)


def run():
    #load credentials
    with open("data/foursquare_api_secret.json") as f:
        credentials = json.load(f)

    # Construct the client object
    client = foursquare.Foursquare(client_id=credentials["client_id"], client_secret=credentials["client_secret"])

    #load zones
    boundary_test = "data/input/north_american_grid"
    lvl2_zones =  "data/input/lvl2 zones"
    calls_per_hour = 5000

    categories = {
        'Medical':  ['4bf58dd8d48988d178941735','4bf58dd8d48988d177941735','4bf58dd8d48988d196941735','4bf58dd8d48988d104941735','4d954af4a243a5684765b473'],
        'Ski Area': ['4bf58dd8d48988d1e9941735'],
        'Airport':   ['4bf58dd8d48988d1ed931735'],
        'Hotel':    ['4bf58dd8d48988d1fa931735'],
        'Nightlife':    ['4d4b7105d754a06376d81259'],
        'Outdoors':     ['52e81612bcbc57f1066b7a21','52e81612bcbc57f1066b7a13','4bf58dd8d48988d162941735','4bf58dd8d48988d1e4941735','4bf58dd8d48988d165941735'],
        'Sightseeing':  ['4bf58dd8d48988d1e2931735','4deefb944765f83613cdba6e','4bf58dd8d48988d181941735','4bf58dd8d48988d182941735','4bf58dd8d48988d165941735']
    }

    with collection(boundary_test, "r") as zones:
        #get_venues_for_zones(client, zones)
        #get_venues_for_zones(client, zones, categories_string)
        for cat in categories:
            cat_string = ','.join(categories[cat])
            get_venues_for_zones(client, zones, cat_string)


run()