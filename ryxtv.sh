# desc: Plays custom format .csv files (made for iptv but can be adapted) with mpv
# usage: ./ryxtv.sh {filename.csv}

#!/bin/bash

input="$1"

mapfile -t lines < <(grep -vE '^\s*$|^\s*#' "$input")

names=()
groups=()
countries=()
links=()
entries=()
index=-1
longest=0;

for line in "${lines[@]}"; do
  IFS=';' read -ra fields <<< "$line"
  for i in "${!fields[@]}"; do
    # Trim whitespace
    fields[$i]="${fields[$i]#"${fields[$i]%%[![:space:]]*}"}"
    fields[$i]="${fields[$i]%"${fields[$i]##*[![:space:]]}"}"
  done

  names+=("${fields[0]}")
  groups+=("${fields[1]}")
  countries+=("${fields[2]}")
  links+=("${fields[3]}")

  if (( ${#fields[0]} > $longest )); then
    longest="${#fields[0]}"
  fi
done

padding=$((longest+5))

for i in "${!names[@]}"; do
  name=${names[$i]};
  group=${groups[$i]};
  country=${countries[$i]};

  line=$(printf "%-${padding}s" "$name") 
  line+="|"
  line+=$(printf "%-10s" "$group")
  line+="|"
  line+=$country

  entries+=("$line")
done

while true; do
  target=$(printf '%s\n' "${entries[@]}" | fzf --layout reverse --border)

  if [ $? -eq 130 ]; then
    break
  fi

  for i in "${!entries[@]}"; do
    if [[ "${entries[$i]}" == "$target" ]]; then
      index=$i
      break
    fi
  done

  link=${links[$index]}
  # echo "Link: $link"
  url=$(yt-dlp -g "$link")

  # echo "Url: $url"
  mpv $url
done
