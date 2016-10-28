#given data dictionary and file, build a csv of values
import json
import pprint
#process dd into format
pp = pprint.PrettyPrinter()

a = {
        "length":1,
        "answers":{"code":"Answer"}
    }

def get_headers(js):
    return [v["Variable Name"] for v in js]

def get_headers_long(js):
    return [v["Question Name"] for v in js]

def build_dd(js):
    return [(v["Position"],v["Length"],{a["Code"]:a["Answer"] for a in v["Answers"] if "Answer" in a}) for v in js]

def decode(answers, value):
    try:
        return answers[value]
    except KeyError:
        #just return the int value
        return value


#dd = "data/ITS/PUMF_Canadians_E.json"
#data = "data/ITS/data/2013/ITS_CDN_2013_PUMF.txt"

dd = "data/input/ITS/VISAE.json"
data = "data/input/ITS/2013/VISAE_ITS_2013_PUMF.txt"
output = "data/input/ITS/2013/out_VISAE_ITS_2013_PUMF.txt"

with open(dd, 'r') as src:
    j = json.load(src)
    num_variables = len(j)
    headers =  get_headers_long(j)
    print headers

d = build_dd(j)

#pp.pprint(d)

with open(data, 'r') as src:
    with open(output, 'w') as out:
        out.write("\t".join(headers).encode('utf8'))
        out.write("\n".encode('utf8'))
        for line in src:
            #print line
            decoded_line = [line[pos-1:(pos-1)+length] for (pos, length, answers) in d]
            assert (len(decoded_line) == num_variables)

            out.write(",".join(decoded_line).encode('utf8'))
            out.write("\n".encode('utf8'))



