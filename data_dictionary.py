# -*- coding: utf-8 -*-
import string
import pprint
import re
import io, codecs
import json

FIRST_INDENT = 8
SECOND_INDENT = 35
THIRD_INDENT = 61
FOURTH_INDENT = 100
INDENTS = [0, FIRST_INDENT, SECOND_INDENT, THIRD_INDENT, FOURTH_INDENT, None]

pp = pprint.PrettyPrinter(indent=4)
first_line_regex = re.compile("""\s+Variable Name:\s+(\w+)\s+Length: *(\d+\.\d+)\s+Position: *(\d+)""")

def parse_element(content,row, indent_start, indent_end):
    if indent_end is None:
        return content[row][INDENTS[indent_start]:].strip()
    else:
        return content[row][INDENTS[indent_start]:INDENTS[indent_end]].strip()

def atoi(s):
    stripped = s.replace(',', '').partition(".")[0]
    return int(stripped)

def atof(s):
    stripped = s.replace(',', '')
    return float(stripped)

def find_source_heading(content):
    count = 0
    for line in content:
        count += 1
        if "Source:" in line:
            return count

def parse_answer_code(code_string):
    code = None
    try:
        int(code_string)
    except:
        pass #should we return the hypenated range? i.e. 00000-23100
    return code

def parse_section_meta_data(content):
    ss = " ".join(map(string.strip,content)).replace('\n', "")
    vars = ["Question Name", "Concept", "Question Text","Universe", "Note" ]
    end = "Source"
    vars_reg = [v+""":\s*(.*?)\s*""" for v in vars]
    reg = "".join(vars_reg) + end
    #print reg
    m = re.match(reg,ss)

    return dict(zip(vars, m.groups()[1:]))

def parse_section(content):
    try:
        matches = first_line_regex.match(content[0])
        others = parse_section_meta_data(content[1:])

        start_of_answers = find_source_heading(content)

        #split each line into name and values, trim whitespace
#        others = dict(tuple(map(string.strip, l.strip().split(":", 1))) for l in content[1:6])

        metadata = {
            "Variable Name":matches.group(1), #Variable Name
            "Length":matches.group(2),
            "Position":int(matches.group(3)),
        }
        metadata.update(others)
        answers = map(parse_answer, content[start_of_answers:-1])#lines should start at "Source:", plus two lines, skip total line

        metadata["Answers"] = answers
    except:
        print "failed on: "
        print "".join(content)
        pp.pprint(content)
        raise

    return metadata

def parse_answer(line):
    matches = re.match(r"\s*(.*?)([\d.]+\s?-\s?[\d.]+|\d+)\s+([\d,]+)\s+([\d+,?]+)\s+([]\d.]+)", line) #tweaked to accomodate 0%
    d = {}
    try:
        answer = matches.group(1).strip()

        if answer == "United Kingdom, England, Scotland,":
            answer = "United Kingdom, England, Scotland, Wales"
        elif answer == "Dutch West Indies, Netherlands Antilles,":
            answer = "Dutch West Indies, Netherlands Antilles, Saint Eustatius"
        elif answer == "Directly from another country other than":
            answer = "Directly from another country other than the United States"

        elif answer == "Reference month is January, February or":
            answer = "Reference month is January, February or March"
        elif answer == "Reference month is July, August or":
            answer = "Reference month is July, August or September"
        elif answer == "Reference month is October, November or":
            answer = "Reference month is October, November or December"

        elif answer == "Less than high school graduation":
            answer = "Less than high school graduation Certificate"
        elif answer == "Somepost-secondary/Post-secondary":
            answer = "Some post-secondary/Post-secondary certificate or diploma"
        elif answer == u"University degree (Bachelor’s, Master’s or":
            answer = u"University degree (Bachelor’s, Master’s or PhD)"

        elif answer == "Personal conference, convention or trade":
            answer = "Personal conference, convention or trade show"

        elif answer == "Attend a performance such as a play or":
            answer = "Attend a performance such as a play or concert"
        elif answer == "Attend an aboriginal event (pow wow, ":
            answer = "Attend an aboriginal event (pow wow, performance, other)"
        elif answer == "Attend a business/other":
            answer = "Attend a business/other meeting/conference/seminar"

        d = {
                    "Answer": answer,
                    "Code":matches.group(2),
                    "Frequency":atoi(matches.group(3)),
                    "WeightedFrequency":atoi(matches.group(4)),
                    "Percent":atof(matches.group(5))
                }
    except:
        if line.strip() not in ["Wales", "Saint Eustatius", "the United States"]: #these cases are handled above
            print line
    return d

def segment(lines):
    segments = []
    current_seg = []
    for l in lines:
        if l.lstrip().startswith("Variable Name:"):
            current_seg = []
            segments.append(current_seg)
        if ( #skip page headers
                "Totals may not add up due to rounding." not in l
                and not re.search("""Page\d+ ?- ?\d+""", l)
                and not re.search("""Data\s?Dictionary""", l)
                and not "Visit" == l.strip()
                and not "Person-Month" in l.strip()
                and not "Trip" == l.strip()
                and "AnswerCategories" not in l
        ):
            current_seg.append(l)
        else:
            pass #ignore anything else

    return segments

def run_test(test_file, encoding=None):
    print "running test: ", test_file
    with io.open(test_file, 'r', encoding=encoding) as input:
        content = input.readlines()
        sections = segment(content)
        #pp.pprint(sections)
        var_def = map(parse_section, sections)
    return var_def
        #pp.pprint(var_def)

def process_and_export(infile, outfile, encoding=None):
    result = run_test(infile, encoding)
    with open(outfile, 'w') as out:
        json.dump(result, out, sort_keys=True,indent=4, encoding='utf-8')

def test():
    r1 = run_test("data/test_1.txt")

    r2 = run_test("data/test_2_2page.txt")

    r3 = run_test("data/test_3_2page.txt")

    assert(r1 == r2)
    assert(r1 == r3)

import sys

process_and_export("ITS/dd/PUMF_Canadians_E.txt","ITS/PUMF_Canadians_E.json", encoding="utf-16")
process_and_export("ITS/dd/PUMF_Visitors_E.txt","ITS/PUMF_Visitors_E.json", encoding="utf-16")
process_and_export("TSRC/dd/Person_TSRC.txt","TSRC/Person_TSRC.json", encoding="utf-16")
process_and_export("TSRC/dd/Trip_TSRC.txt","TSRC/Trip_TSRC.json", encoding="utf-16")
process_and_export("TSRC/dd/Visit_TSRC.txt","TSRC/Visit_TSRC.json", encoding="utf-16")



#Lines to delete:
#    2015-05-28                                                                                  Page41-116
#       Totals may not add up due to rounding.
#                                                ITS 2013 - Data Dictionary
#
#    Page40 - 116                                                                                  2015-05-28
#       Totals may not add up due to rounding.
#                                                ITS 2013 - Data Dictionary
