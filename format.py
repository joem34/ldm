#given data dictionary and file, build a csv of values
import json
import pprint
#process dd into format
pp = pprint.PrettyPrinter()

a = {
        "length":1,
        "answers":{"code":"Answer"}
    }

def build_dd(js):
    return [(v["Position"],v["Length"],{a["Code"]:a["Answer"] for a in v["Answers"] if "Answer" in a}) for v in js]

def decode(answers, value):
    try:
        return answers[value]
    except KeyError:
        #just return the int value
        return value

with open("data/ITS/PUMF_Canadians_E.json", 'r') as src:
    j = json.load(src)

d = build_dd(j)

#pp.pprint(d)

with open("data/ITS/data/2014/ITS_CDN_2014_PUMF.txt", 'r') as src:
    for line in list(src)[:10]:
        print[decode(answers, line[pos-1:(pos-1)+length]) for (pos, length, answers) in d]



