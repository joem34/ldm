import time
import foursquare
import json
from fiona import collection
from fiona.crs import to_string
from functools import partial
import pyproj
from pyproj import Proj
from shapely.ops import transform
from shapely.geometry import shape


#load credentials
with open("data/foursquare_api_secret.json") as f:
    credentials = json.load(f)

# Construct the client object
client = foursquare.Foursquare(client_id=credentials["client_id"], client_secret=credentials["client_secret"])

"ne, sw"
test_box = {"n":48.64,"e":-89.6, "s":48.18, "w": -88.755 }
if False:
    try:
        #venues = client.venues.search(params={'intent':'browse', 'near':'toronto', 'radius':5000})
        venues = client.venues.search(params={'intent':'browse', 'ne': "45,-79", "sw":"44,-80", 'limit':100})
    except (foursquare.ParamError, foursquare.EndpointError) as e:
        print e
        exit()

    print len(venues['venues']), sum([v['stats']['checkinsCount'] for v in venues['venues']])

#need to run venue search for every 10km^2.
search_box = {"n":48.64,"e":-89.6, "s":48.18, "w": -88.755 }


#load zones
with collection("input/internalZones", "r") as zones:
    zones_crs = Proj(to_string(zones.crs))
    fs_crs = Proj(init='epsg:4326')

    project = partial(pyproj.transform, zones_crs, fs_crs) # destination coordinate system


    #get boundary
    #nw = transform(zones_crs, fs_crs, zones.bounds[0], zones.bounds[1])
    #se = transform(zones_crs, fs_crs, zones.bounds[2], zones.bounds[3])

    #print "boundary:", nw, se
    all_venues = {}
    i = 0
    try:
        for poly in zones:
            poly1 = transform(project, shape(poly['geometry']))  # apply projection
            bbox = poly1.bounds
            (west, south, east, north) = tuple(bbox)
            ne = str(north) + ',' +  str(east)
            sw = str(south) + ',' +  str(west)
            params={'intent':'browse', 'ne': ne, "sw":sw , 'limit':100}
            #print params
            (nl, el, sl, wl) = (44.6, -80, 43.2, -81.8)
            #if north < nl and east < el and south > sl and west > wl:
            if north > 44:
                zone_id = int(poly['properties']['ID'])
                venues = client.venues.search(params=params)
                num_venues = len(venues['venues'])
                num_checkins = sum([v['stats']['checkinsCount'] for v in venues['venues']])
                print i, ":", (south, west), zone_id, num_venues, num_checkins
                all_venues[poly['properties']['ID']] = {
                    "bbox": { "n": north, "s": south, "e":east, "w":west },
                    "venues": venues['venues']
                }
                i += 1
    except (foursquare.ParamError, foursquare.EndpointError) as e:
        print e
        exit()

    finally:
        with open("output/venues_%s.json" % time.strftime("%Y%m%d-%H%M%S"), 'w') as out:
            json.dump(all_venues, out)

    #can use 111.32km/degree as rough estimate

    #convert boundary to grid


    # process each grid for venues.






#strip venue to id, category and checkin count

#in larger external zones, possibly only retrieve foursquare data for urban centres

#how do we account for number of users in a certain area? population?