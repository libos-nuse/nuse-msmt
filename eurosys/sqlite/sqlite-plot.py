#!/usr/bin/env python

import csv
import os
import pickle
from statistics import mean, stdev
import sys

benchmarks = ["fillseq", "fillrandom", "readseq", "readrandom"]
platforms = ["native", "lkl", "runc", "runsc-ptrace", "kata-runtime"]
sizes = [128, 256, 512, 1024, 1500, 4096, 8192]

def parse_info(filename):
    assert "sqlite-bench" in filename
    info = {}
    for bench in benchmarks:
        if bench in filename:
            info["benchmark"] = bench
            break
    for platform in platforms:
        if platform in filename:
            info["platform"] = platform
            break
    for size in sizes:
        if "vs" + str(size) in filename:
            info["size"] = size
            break
    # TODO: Add trials info

    return info

def read_dat(datfp):
    dat = []
    csvreader = csv.reader(datfp)
    for row in csvreader:
        if len(row) < 2:
            continue
        try:
            dat.append(float(row[1]))
        except ValueError:
            continue

    return dat

def stat_dat(benchmark, platform, all_dat):
    cands = {}
    for key, dat in all_dat.items():
        if benchmark in key and platform in key:
            cands[dat["info"]["size"]] += dat["data"]
    stat = {}
    for key, dat in cands:
        stat[key] = {"mean": mean(dat), "stddev": stdev(dat)}

    return stat

def main():
    if len(sys.argv) < 2:
        return -1

    src_path = sys.argv[1]
    dst_path = os.path.join(src_path, "all_dat.pickle")

    src_dir = os.listdir(src_path)
    all_dat = {}
    for filename in src_dir:
        if not filename.endswith(".dat") or not "sqlite-bench" in filename:
            continue
        path = os.path.join(src_path, filename)
        info = parse_info(filename)
        with open(path, "r") as fp:
            dat = read_dat(fp)
            all_dat[filename] = {"info": info, "data": dat}

    with open(dst_path, "wb") as fp:
        pickle.dump(all_dat, fp)

    for benchmark in benchmarks:
        for platform in platforms:
            stat = stat_dat(benchmark, platform, all_dat)
            filename = benchmark + "-" + platform + ".dat"
            path = os.path.join(src_path, filename)
            with open(path, "w") as fp:
                fp.write("# mean stddev\n")
                for (size, stat) in sorted(stat.items()):
                    fp.write("{}\t{}\n".format(stat["mean"], stat["stddev"]))

    return 0

if __name__ == "__main__":
    sys.exit(main())
