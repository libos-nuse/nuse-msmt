#!/usr/bin/env python3

import argparse
import datetime
import re

def round_unit(datestr, unittype):
    """
    datestr: YYYY-M-DD HH:MM:SS -XXXX
    unittype: one of "day", "week", or "month"
    """

    s = datestr.split(" ")
    
    (year, month, day) = map(int, s[0].split("-"))    
    (hour, minute, second) = map(int, s[1].split(":"))
    diff = int(s[2]) / 100
    
    dt = datetime.datetime(year, month, day, hour, minute, second)
    dt = dt - datetime.timedelta(hours = diff)

    if unittype == "day":
        return "{}-{:02}-{:02}".format(dt.year, dt.month, dt.day)

    elif unittype == "week":
        dt = dt - datetime.timedelta(days = dt.weekday())
        return "{}-{:02}-{:02}".format(dt.year, dt.month, dt.day)

    elif unittype == "month":
        return "{}-{:02}-{:02}".format(dt.year, dt.month, 1)

    elif unittype == "year":
        return "{}-06-01".format(dt.year)
        

def parse(args):

    regx_commitid = re.compile(r"[a-z0-9]{40}")
    unit = None

    result = {} # { unit: (+, -, # of commit) }

    with open(args.gitlog, "r", encoding='utf-8', errors='ignore') as f:
        for line in f:

            line = line.strip()

            if regx_commitid.match(line):
                # this is commit line
                s = line.split(" ")
                datestr = "{} {} {}".format(s[1], s[2], s[3])
                unit = round_unit(datestr, args.unit)

                if not unit in result:
                    result[unit] = [0, 0, 0]

                result[unit][2] += 1

            elif not line:
                continue

            else:
                # numstat line
                line = re.sub(r"\s+", " ", line)
                (loadd, lodel, src) = line.split(" ", 2)
                try:
                    result[unit][0] += int(loadd)
                    result[unit][1] += int(lodel)
                except:
                    # numstat outputs '-' for binary
                    pass
                    
    return result
                    
                    

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("-u", "--unit",
                        choices = ["day", "week", "month", "year"],
                        default = "week", help = "unit of totaling")
    parser.add_argument("gitlog", help = "target git log output file")

    args = parser.parse_args()

    res = parse(args)

    print("#Date\t\tAdd\tDel\tCommit")
    for k, v in res.items():
        print("{}\t{}\t{}\t{}".format(k, v[0], v[1], v[2]))



if __name__ == "__main__":
    main()
