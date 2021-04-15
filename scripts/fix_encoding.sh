#!/bin/sh
# Fix file encoding to UTF-8
set -e

echo $(date -Iseconds)" INFO - Script name: $0"

if [ -z "$1" ]; then
  echo $(date -Iseconds)" ERROR - No parameters found."
  exit
fi

if [ "$1" != "-f" ]; then
  echo $(date -Iseconds)" ERROR - No expected parameter (-f </path/to/file/filename>)."
  exit
fi

if [ -z "$2" ] || [ ! -f "$2" ]; then
  echo $(date -Iseconds)" ERROR - No file found ("$2")."
  exit
fi

fe=$(echo $(file -b --mime-encoding "$2") | awk '{print toupper($0)}')
echo $(date -Iseconds)" INFO - File: $2"
echo $(date -Iseconds)" INFO - File encoding: $fe"

# utf-8
if [ $fe != "UTF-8" ]; then
  cat $2 > $2.bak
  iconv -f $fe -t "UTF-8" $2.bak -o $2
  rm $2.bak
  echo $(date -Iseconds)" INFO - File encoding done."
else
  echo $(date -Iseconds)" INFO - File in UTF-8. There is nothing to fix..."
fi

# \xc2\xa0
if [ -n "$(cat -v $2 | sed 's/\xc2\xa0/ /g')" ]; then
  cat $2 > $2.bak
  cat $2.bak | sed 's/\xc2\xa0/ /g' > $2
  rm $2.bak
  echo $(date -Iseconds)" INFO - Fix \xc2\xa0 done."
else
  echo $(date -Iseconds)" INFO - No \xc2\xa0 entries..."
fi
