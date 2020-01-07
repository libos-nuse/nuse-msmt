#!/usr/bin/env python3

import subprocess
import datetime
import sys
import re


def parse_m(commit, gitrepo):

    items = 0
    fixes = 0

    regx_item = re.compile(r"\d+\)")

    cmd = ["git", "-C", gitrepo, "show", "{}:m".format(commit)]
    out = subprocess.check_output(cmd).decode(errors = "ignore")

    is_content = False
    for line in out.split("\n"):
        
        if ("Subject: [GIT] Networking" in line or
            "Subject: [GIT]: Networking" in line) :
            is_content = True

        elif is_content and regx_item.match(line):

            items += 1
            if " Fix " in line or " fix " in line:
                fixes += 1

        elif "Please pull, thanks a lot!" in line:
            break


    return items, fixes


def parse(commitlist, gitrepo, items_all, items_fix):

    with open(commitlist, "r") as f:
        lines = f.read().split("\n")
        lines.reverse() # we need to read from past 

    for line in lines:

        line = line.strip()
        if not line: continue

        commit, date = line.split(" ")[0:2]
        items, fixes = parse_m(commit, gitrepo)

        #if not items or items < fixes:
            #print("something wrong at {}".format(commit), file = sys.stderr)
            
        items_all += items
        items_fix += fixes

        print("{}\t{}\t{}\t{}\t{}".format(date, items_all, items_fix,
                                          items_all - items_fix, commit))

    return items_all, items_fix


def main():

    items_all = 0
    items_fix = 0

    print("#{}\t\t{}\t{}\t{}".format("Date", "All", "Fix", "All-minus-Fix"))

    items_all, items_fix = parse("git/commits-0.git.txt", "git/0.git",
                                 items_all, items_fix)
    items_all, items_fix = parse("git/commits-1.git.txt", "git/1.git",
                                 items_all, items_fix)



if __name__ == "__main__":
    main()
