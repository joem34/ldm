import json

with open("input/fs_venue_categories.json") as f:
    categories = json.load(f)['response']['categories']

for cat in categories:
    print "%s | %s | %s" % (cat['name'], "", "")
    for cat1 in cat['categories']:
        print "%s | %s | %s" % (cat['name'], cat1['name'], "")
        for cat2 in cat1['categories']:
                print "%s | %s | %s" % (cat['name'], cat1['name'], cat2['name'])