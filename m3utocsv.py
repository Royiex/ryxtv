# desc: converts .m3u files to .csv usable with ryxtv
# usage: python3 m3utocsv.py {filename.m3u}
import sys, re

file = sys.argv[1]
with open(file) as f:
    lines = f.readlines()

urlnext = False
channels = []


for line in lines:
    if line.startswith("#EXTINF:"):
        urlnext = True

        country_match = re.search(r'tvg-country="([^"]+)"', line)
        group_match = re.search(r'group-title="([^"]+)"', line)
        country = country_match.group(1) if country_match else "N/A"
        group = group_match.group(1) if group_match else "N/A"

        name = line.split(',')[-1].strip()
        if name[0]==',' or name[0]==' ':
            name = name[1:]

    elif urlnext:
        urlnext = False
        url = line.split('|')[0]
        channels.append([name, group, country, url])

file = sys.argv[1].split('.')[0]
with open(f"{file}.csv", "x") as f:
    for channel in channels:
        f.write(f"{channel[0]};{channel[1]};{channel[2]};{channel[3]}\n")
